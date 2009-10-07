/* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License
 * Version 1.1 (the "License"); you may not use this file except in
 * compliance with the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied.
 * See the License for the specific language governing rights and
 * limitations under the License.
 *
 * The Original Code is Bespin.
 *
 * The Initial Developer of the Original Code is Mozilla.
 * Portions created by the Initial Developer are Copyright (C) 2009
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *   Bespin Team (bespin@mozilla.com)
 *
 * ***** END LICENSE BLOCK ***** */

dojo.provide("bespin.editor.actions");

// = Actions =
//
// The editor can run various actions. They are defined here and you can add or change them dynamically. Cool huh?
//
// An action mutates the model or editor state in some way. The only way the editor state or model should be manipulated is via
// the execution of actions.
//
// Actions integrate with the history manager by including instructions for how to undo (and redo) the action. These instructions
// take the form of a hash containing the necessary state for undo/redo. A key "action" corresponds to the function name of the
// action that should be executed to undo or redo the operation and the remaining keys correspond to state necessary to perform
// the action. See below for various examples.
//
// The undo/redo action object is defined at the bottom of this file.

dojo.declare("bespin.editor.Actions", null, {
    constructor: function(editor) {
        this.editor = editor;
        this.model = this.editor.model;
        this.cursorManager = this.editor.cursorManager;
        this.ignoreRepaints = false;
        
        this.currentEditItem = undefined;
        this.editDepth = 0;
    },
    
    // history: begin an edit item. Call before making an edit. If any edit is already in progress,
    // this will just be part of that edit.
    beginEdit: function(name) {
        if (this.editDepth == 0) {
            this.currentEditItem = new bespin.editor.ActionHistoryItem(name, this.editor);
            this.currentEditItem.begin();
        }
        this.editDepth++;
    },
    
    endEdit: function() {
        if (this.editDepth <= 0)
            return;
        
        this.editDepth--;
        
        if (this.editDepth == 0) {
            this.currentEditItem.end();
            this.editor.historyManager.add(this.currentEditItem);
            this.currentEditItem = undefined;
        }
    },
    
    // this is a generic helper method used by various cursor-moving methods
    handleCursorSelection: function(args) {
        if (args.event.shiftKey) {
            if (!this.editor.selection) this.editor.setSelection({ startPos: bespin.editor.utils.copyPos(args.pos) });
            this.editor.setSelection({ startPos: this.editor.selection.startPos, endPos: bespin.editor.utils.copyPos(this.cursorManager.getCursorPosition()) });
        } else {
            this.editor.setSelection(undefined);
        }
    },

    moveCursor: function(moveType, args) {
        var posData = this.cursorManager[moveType](args);
        this.handleCursorSelection(args);
        this.repaint();
        args.pos = posData.newPos;
        return args;
    },

    moveCursorLeft: function(args) {
        return this.moveCursor("moveLeft", args);
    },

    moveCursorRight: function(args) {
        return this.moveCursor("moveRight", args);
    },

    moveCursorUp: function(args) {
        return this.moveCursor("moveUp", args);
    },

    moveCursorDown: function(args) {
        return this.moveCursor("moveDown", args);
    },

    moveToLineStart: function(args) {
        return this.moveCursor("moveToLineStart", args);
    },

    moveToLineEnd: function(args) {
        return this.moveCursor("moveToLineEnd", args);
    },

    moveToFileTop: function(args) {
        return this.moveCursor("moveToTop", args);
    },

    moveToFileBottom: function(args) {
        return this.moveCursor("moveToBottom", args);
    },

    movePageUp: function(args) {
        return this.moveCursor("movePageUp", args);
    },

    movePageDown: function(args) {
        return this.moveCursor("movePageDown", args);
    },

    moveWordLeft: function(args) {
        return this.moveCursor("smartMoveLeft", args);
    },

    moveWordRight: function(args) {
        return this.moveCursor("smartMoveRight", args);
    },

    deleteWordLeft: function(args) {
        //we will begin here (instead of in deleteChunk) so that the cursor state will be kept
        this.beginEdit("deleteWordLeft");
        this.deleteChunk({
            endPos: args.pos,
            pos: this.moveCursor("smartMoveLeft", args).pos
        });
        this.endEdit();
        return args;
    },

    deleteWordRight: function(args) {
        this.beginEdit("deleteWordRight");
        this.deleteChunk({
            pos: args.pos,
            endPos: this.moveCursor("smartMoveRight", args).pos
        });
        this.endEdit();
        return args;
    },

    applyState: function(state)
    {
        if (this.testHistory.length == 0) {
            return;
        } else if (state < 0) {
            state = -1;
        } else if (state >= this.testHistory.length) {
            return;
        }

        this.testHistoryPosition = state;
        var item = this.testHistory[Math.max(0, this.testHistoryPosition)];
        
        var modelState = item.after;
        var editorState = item.uiAfter;
        if (state < 0)
        {
            modelState = item.before;
            editorState = item.uiBefore;
        }
        
        this.model.applyState(modelState);
        this.editor.setState(editorState);
    },

    undo: function() {
        this.editor.historyManager.undo();
    },
    
    redo: function() {
        this.editor.historyManager.redo();
    },
    
    selectAll: function(args) {
        // do nothing with an empty doc
        if (this.model.isEmpty()) return;

        args.startPos = { row: 0, col: 0 };
        args.endPos = { row: this.model.getRowCount() - 1, col: this.editor.ui.getRowScreenLength(this.model.getRowCount() - 1) };

        this.select(args);
    },

    select: function(args) {
        if (args.startPos) {
            this.editor.setSelection({ startPos: args.startPos, endPos: args.endPos });
            this.cursorManager.moveCursor(args.endPos);
        } else {
            this.editor.setSelection(undefined);
        }
    },

    insertTab: function(args) {
        if (this.editor.readonly) return;

        var settings = bespin.get("settings");

        if (this.editor.getSelection() && !args.undoInsertTab) {
            this.indent(args);
            return;
        }

        var tab = args.tab;
        var tablength = this.cursorManager.getCharacterLength("\t");

        if (!tab || !tablength) {
            if (settings && settings.isSettingOn('tabmode')) {
                // do something tabby
                tab = "\t";
            } else {
                tab = "";
                var tabSizeCount = tablength;
                while (tabSizeCount-- > 0) {
                    tab += " ";
                }
                tablength = tab.length;
            }
        }

        this.beginEdit("insertTab");

        delete this.editor.selection;
        this.model.insertCharacters(this.cursorManager.getModelPosition({ row: args.pos.row, col: args.pos.col }), tab);
        this.cursorManager.moveCursor({ row: args.pos.row, col: args.pos.col + tablength });
        this.repaint();

        this.endEdit();
    },

    indent: function(args) {
        this.beginEdit("indent");

        var settings = bespin.get('settings');
        var selection = this.editor.getSelection();
        var unsetSelection = false;

        if (selection === undefined) {
            unsetSelection = true;
            var cursorPos = this.editor.getCursorPos();
            var modelPos = this.editor.getModelPos();

            selection = {
                startPos: { row: cursorPos.row, col: 0 },
                endPos: { row: cursorPos.row, col: this.model.getRowMetadata(cursorPos.row).lineLength },
                startModelPos: { row: modelPos.row, col: 0 },
                endModelPos: { row: modelPos.row, col: this.model.getRowMetadata(modelPos.row).lineLengthWithoutTabExpansion }
            };

            this.editor.setSelection(selection);
        }

        var startRow = selection.startPos.row;
        var endRow = selection.endPos.row;
        var endRowLength = this.cursorManager.getStringLength(this.model.getRowArray(endRow).join(""));
        var cursorRowLength = this.cursorManager.getStringLength(this.model.getRowArray(args.pos.row).join(""));
        var charsToInsert;
        var tab = '';
        if (settings && settings.isSettingOn('tabmode')) {
            tab = "\t";
        } else {
            var tabsize = this.editor.getTabSize();
            while (tabsize-- > 0) {
                tab += " ";
            }
        }

        for (var y = startRow; y <= endRow; y++) {
            if (tab != '\t') {
                charsToInsert = this.cursorManager.getLeadingWhitespace(y);
                charsToInsert = this.cursorManager.getNextTablevelRight(charsToInsert) - charsToInsert;
                charsToInsert = tab.substring(0, charsToInsert);
            } else {
                // in the case of "real" tabs we just insert the tabs
                charsToInsert = '\t';
            }
            this.model.insertCharacters(this.cursorManager.getModelPosition({ row: y, col: 0 }), charsToInsert);
        }

        var delta = this.cursorManager.getStringLength(this.model.getRowArray(args.pos.row).join("")) - cursorRowLength;
        selection.endPos.col += this.cursorManager.getStringLength(this.model.getRowArray(endRow).join("")) - endRowLength;
        this.editor.setSelection(selection);
        this.cursorManager.moveCursor({ col: args.pos.col + delta });

        if(unsetSelection) {
            this.editor.setSelection(undefined);
        }

        this.repaint();
        
        this.endEdit();
    },

    unindent: function(args) {
        this.beginEdit("unindent");

        var selection = this.editor.getSelection();
        var unsetSelection = false;

        if (selection === undefined) {
            unsetSelection = true;
            var cursorPos = this.editor.getCursorPos();
            var modelPos = this.editor.getModelPos();

            selection = {
                startPos: { row: cursorPos.row, col: 0 },
                endPos: { row: cursorPos.row, col: this.model.getRowMetadata(cursorPos.row).lineLength },
                startModelPos: { row: modelPos.row, col: 0 },
                endModelPos: { row: modelPos.row, col: this.model.getRowMetadata(modelPos.row).lineLengthWithoutTabExpansion }
            };

            this.editor.setSelection(selection);
        }

        var startRow = selection.startPos.row;
        var endRow = selection.endPos.row;
        var endRowLength = this.cursorManager.getStringLength(this.model.getRowArray(endRow).join(""));
        var row = false;
        var charsToDelete;
        var charsWidth;
        
        for (var y = startRow; y <= endRow; y++) {
            row = this.model.getRowArray(y);
            if (row.length > 0 && row[0] == '\t') {
                charsToDelete = 1;
                charsWidth = this.editor.getTabSize();
            } else {
                var leadingWhitespaceLength = this.cursorManager.getLeadingWhitespace(y);
                charsToDelete = this.cursorManager.getContinuousSpaceCount(0, this.editor.getTabSize(), y);
                charsWidth = charsToDelete;
            }

            if (charsToDelete) {
                this.model.deleteCharacters(this.cursorManager.getModelPosition({ row: y, col: 0 }), charsToDelete);
            }
            if (y == startRow) {
                selection.startPos.col = Math.max(0, selection.startPos.col - charsWidth);
            }
            if (y == endRow) {
                if (!row) row = this.model.getRowArray(y);
                var delta = endRowLength - this.cursorManager.getStringLength(row.join(""));
                selection.endPos.col = Math.max(0, selection.endPos.col - delta);
                args.pos.col = Math.max(0, args.pos.col - delta);
            }
        }
        this.editor.setSelection(selection);
        this.cursorManager.moveCursor({ col: args.pos.col });

        if(unsetSelection) {
            this.editor.setSelection(undefined);
        }

        this.repaint();        

        this.endEdit();
    },

    // NOTE: Actually, clipboard.js is taking care of this unless EditorOnly mode is set
    cutSelection: function(args) {
        if (this.editor.readonly) return;

        this.beginEdit('cut');
        this.copySelection(args);
        this.deleteSelection(args);
        this.endEdit();
    },

    // NOTE: Actually, clipboard.js is taking care of this unless EditorOnly mode is set
    copySelection: function(args) {
        var selectionObject = this.editor.getSelection();
        if (selectionObject) {
            var selectionText = this.model.getChunk(selectionObject);
            if (selectionText) {
                bespin.editor.clipboard.Manual.copy(selectionText);
            }
        }
    },

    // NOTE: Actually, clipboard.js is taking care of this unless EditorOnly mode is set
    pasteFromClipboard: function(args) {
        if (this.editor.readonly) return;

        var clipboard = (args.clipboard) ? args.clipboard : bespin.editor.clipboard.Manual.data();
        if (clipboard === undefined) return; // darn it clipboard!
        args.chunk = clipboard;
        this.beginEdit('paste');
        this.insertChunk(args);
        this.endEdit();
    },

    insertChunk: function(args) {
        if (this.editor.readonly) return;

        this.beginEdit("insertChunk");

        if (this.editor.selection) {
            this.deleteSelection();
        }
        
        var pos = bespin.editor.utils.copyPos(this.cursorManager.getCursorPosition());
        pos = this.model.insertChunk(this.cursorManager.getModelPosition(pos), args.chunk);
        pos = this.cursorManager.getCursorPosition(pos);
        this.cursorManager.moveCursor(pos);
        this.repaint();

        //undo/redo
        this.endEdit();

        return pos;
    },

    deleteChunk: function(args) {
        if (this.editor.readonly) return;

        this.beginEdit("deleteChunk");

        // Sometimes we're passed a selection, and sometimes we're not.
        var startPos = (args.startPos != undefined) ? args.startPos : bespin.editor.utils.copyPos(args.pos);

        var selection = this.editor.getSelection({ startPos: startPos, endPos: args.endPos });
        var chunk = this.model.deleteChunk(selection);
        this.cursorManager.moveCursor(selection.startPos);
        this.editor.setSelection(undefined);
        this.repaint();
        
        //undo/redo
        this.endEdit();
        
        return selection.startPos;
    },

    joinLine: function(args) {
        if (this.editor.readonly) return;

        this.beginEdit("joinLine");

        if (args.joinDirection == "up") {
            if (args.pos.row == 0) return;

            var newcol = this.editor.ui.getRowScreenLength(args.pos.row - 1);
            this.model.joinRow(args.pos.row - 1);
            this.cursorManager.moveCursor({ row: args.pos.row - 1, col: newcol });
        } else {
            if (args.pos.row >= this.model.getRowCount() - 1) return;

            this.model.joinRow(args.pos.row);
        }

        this.endEdit();

        this.repaint();
    },

    killLine: function(args) {
        if (this.editor.readonly) return;

        this.beginEdit("killLine");

        // select the current row
        this.editor.setSelection({ startPos: { row: args.pos.row, col: 0 }, endPos: { row: args.pos.row + 1, col: 0 } });
        this.cutSelection(args); // cut (will save and redo will work)
        
        this.endEdit();
    },

    deleteSelection: function(args) {
        if (this.editor.readonly) 
            return;

        var selection = this.editor.getSelection();
        return this.deleteChunk({startPos: selection.startPos, endPos: selection.endPos, clearSelection:true});
    },

    backspace: function(args) {
        if (this.editor.readonly) return;

        this.beginEdit("backspace"); // so we capture cursor movement.

        if (this.editor.selection) {
            this.deleteSelection(args);
        } else {
            if (args.pos.col > 0) {
                var settings = bespin.get('settings');
                if (settings && settings.isSettingOn('smartmove')) {
                    var tabsize = this.editor.getTabSize();
                    var freeSpaces = this.cursorManager.getContinuousSpaceCount(args.pos.col, this.cursorManager.getNextTablevelLeft(args.pos.col));
                    if (freeSpaces == tabsize) {
                        var pos = args.pos;
                        this.editor.selection = { startPos: { row: pos.row, col: pos.col - tabsize}, endPos: {row: pos.row, col: pos.col}};
                        this.deleteSelection(args);
                        this.endEdit();
                        return;
                    }
                }
                
                this.cursorManager.moveCursor({ col:  Math.max(0, args.pos.col - 1) });
                args.pos.col -= 1;
                this.deleteCharacter(args);
            } else {
                args.joinDirection = "up";
                this.joinLine(args);
            }
        }
        
        this.endEdit();
    },

    deleteKey: function(args) {
        if (this.editor.readonly) return;

        this.beginEdit("deleteKey");

        if (this.editor.selection) {
            this.deleteSelection(args);
        } else {
            if (args.pos.col < this.editor.ui.getRowScreenLength(args.pos.row)) {
                var settings = bespin.get('settings');
                if (settings && settings.isSettingOn('smartmove')) {
                    var tabsize = this.editor.getTabSize();
                    var freeSpaces = this.cursorManager.getContinuousSpaceCount(args.pos.col, this.cursorManager.getNextTablevelRight(args.pos.col));
                    if (freeSpaces == tabsize) {
                        var pos = args.pos;
                        this.editor.selection = { startPos: { row: pos.row, col: pos.col }, endPos: { row: pos.row, col: pos.col + tabsize } };
                        this.deleteSelection(args);
                        this.endEdit();
                        return;
                    }
                }
                this.deleteCharacter(args);
            } else {
                args.joinDirection = "down";
                this.joinLine(args);
            }
        }
        
        this.endEdit();
    },

    deleteCharacter: function(args) {
        if (this.editor.readonly) return;

        if (args.pos.col < this.editor.ui.getRowScreenLength(args.pos.row)) {
            this.beginEdit("deleteCharacter");
            
            var modelPos = this.cursorManager.getModelPosition(args.pos);
            
            var length = 1;
            var deleted = this.model.deleteCharacters(modelPos, length);
            this.repaint();

            // undo/redo        
            this.endEdit();
        }
    },

    newline: function(args) {
        if (this.editor.readonly) return;

        var settings = bespin.get("settings");
        if (settings && settings.isSettingOn('autoindent')) {
            var autoindent = bespin.util.leadingWhitespace(this.model.getRowArray(args.pos.row));
        } else {
            var autoindent = [];
        }
        
        args.chunk = "\n" + autoindent.join("");
        this.insertChunk(args);
    },

    newlineBelow: function(args) {
        this.newline(this.moveToLineEnd(args));
    },

    insertCharacter: function(args) {
        if (this.editor.readonly) return;
        
        this.beginEdit("insertCharacter");
        
        var pos = args.pos;
        if (this.editor.selection) {
            // this should end up being a sub-action. Or being supressed. Automatically.
            pos = this.deleteSelection(args);
        }
        
        this.model.insertCharacters(this.cursorManager.getModelPosition(pos), args.newchar);
        this.cursorManager.moveRight(true);

        var settings = bespin.get('settings');
        if (settings && settings.isSettingOn('closepairs')) {
            // Automatically close pairs
            switch(args.newchar) {
                case '(':
                    this.model.insertCharacters(this.cursorManager.getModelPosition(), ')');
                break;

                case '[':
                    this.model.insertCharacters(this.cursorManager.getModelPosition(), ']');
                break;

                case '{':
                    this.model.insertCharacters(this.cursorManager.getModelPosition(), '}');
                break;

                case '<':
                    // TODO: Check for HTML/XML syntax highlighting first, so you don't interfere with value comparisons
//                      this.model.insertCharacters(this.cursorManager.getModelPosition(), '>');
                break;

                case '"':
                    // TODO: Check for proper context, to avoid ' \"" ' situation
//                        this.model.insertCharacters(this.cursorManager.getModelPosition(), '"');
                break;

                case "'":
                    // TODO: Check to make sure this is a single-quotation mark, not an apostrophe
//                      this.model.insertCharacters(this.cursorManager.getModelPosition(), "'");
                break;
            }
        }

        this.repaint();
        
        this.endEdit();
    },

    moveCursorRowToCenter: function(args) {
        var saveCursorRow = this.editor.getCursorPos().row;
        var halfRows = Math.floor(this.editor.ui.visibleRows / 2);
        if (saveCursorRow > (this.editor.ui.firstVisibleRow + halfRows)) { // bottom half, so move down
            this.cursorManager.moveCursor({ row: this.editor.getCursorPos().row + halfRows });
        } else { // top half, so move up
            this.cursorManager.moveCursor({ row: this.editor.getCursorPos().row - halfRows });
        }
        this.editor.ui.ensureCursorVisible();
        this.cursorManager.moveCursor({ row: saveCursorRow });
    },

    getOppositeCase: function(stringCase) {
        if (!stringCase) return undefined;

        switch (stringCase) {
            case 'u':
                return 'l';
            break;

            case 'l':
                return 'u';
            break;
        }
    },

    selectionChangeCase: function(args) {
        if (this.editor.readonly) return;

        //console.log('selectionChangeCase Fired!');
        if (this.editor.selection) {
            this.beginEdit("selectionChangeCase");
            
            if (!args.selectionObject) {
                args.selectionObject = this.editor.getSelection();
            }

            var selection = this.model.getChunk(args.selectionObject);
            var stringArray = selection.split("\n");
            for (i in stringArray) {
                switch (args.stringCase) {
                    case 'l':
                        stringArray[i] = stringArray[i].toLowerCase();
                    break;

                    case 'u':
                        stringArray[i] = stringArray[i].toUpperCase();
                    break;
                }
            }
            var outText = stringArray.join("\n");

            this.model.deleteChunk(args.selectionObject);
            this.model.insertChunk(args.selectionObject.startModelPos, outText);
            this.select(args.selectionObject);
            
            this.endEdit();
        }
    },

    // START SEARCH ACTIONS
    startSearch: function(str, displayType, shiftKey) {
        if (str == '') {
            // nothing to search for? Reset the searchString
            this.editor.ui.setSearchString(false);
            this.editor.paint(true);
            dojo.byId('searchresult').style.display = 'none';
            return false;
        }

        if (str == this.editor.ui.searchString && displayType == 'toolbar') {
            if (!shiftKey) {
                this.findNext();
            } else {
                this.findPrev();
            }
            dojo.byId('searchresult').style.display = 'block';
            return;
        }

        // go and search for the searchString
        this.editor.ui.setSearchString(str);
        var count = this.editor.model.getCountOfString(str);
        if (count != 0) {
            // okay, there are matches, so go on...
            var pos = bespin.editor.utils.copyPos(this.editor.cursorManager.getCursorPosition());

            // first try to find the searchSting from the current position
            if (!this.editor.ui.actions.findNext(null, true)) {
                // there was nothing found? Search from the beginning
                this.editor.cursorManager.moveCursor({col: 0, row: 0 });
                this.editor.ui.actions.findNext();
            }
        }

        // display the count of matches in different ways
        switch (displayType) {
            case 'commandLine':
                var msg = "Found " + count + " match";
                if (count > 1) { msg += 'es'; }
                msg += " for your search for <em>" + str + "</em>";

                bespin.get('commandLine').showHint(msg);
            break;

            case 'searchwindow':
                var filesearch = bespin.get('filesearch');
                if (filesearch) {
                    filesearch.setMatchesCount(count);
                }
            break;

            case 'toolbar':
                var msg = + count + " Match";
                if (count > 1) { msg += 'es'; }
                dojo.byId('searchfeedback').innerHTML = msg;
                dojo.byId('searchresult').style.display = 'block';
            break;
        }

        // repaint the editor
        this.editor.paint(true);
    },

    // find the next match in the file
    findNext: function(event, canBeSamePosition) {
        if (!this.editor.ui.searchString) return;
        var pos = bespin.editor.utils.copyPos(this.cursorManager.getModelPosition());
        var sel = this.editor.getSelection();
        if (canBeSamePosition && sel !== undefined) {
            pos.col -= sel.endModelPos.col - sel.startModelPos.col + 1;
        }
        var found = this.model.findNext(pos.row, pos.col, this.editor.ui.searchString);
        if (!found) found = this.model.findNext(0, 0, this.editor.ui.searchString);
        if (found) {
            this.editor.setSelection({startPos: this.cursorManager.getCursorPosition(found.startPos), endPos: this.cursorManager.getCursorPosition(found.endPos)});
            this.cursorManager.moveCursor(this.cursorManager.getCursorPosition(found.endPos));
            this.editor.ui.ensureCursorVisible(true);
            this.repaint();

            return true;
        } else {
            return false;
        }
    },

    // find the previous match in the file
    findPrev: function() {
        if (!this.editor.ui.searchString) return;

        var pos = this.cursorManager.getModelPosition();
        var found = this.model.findPrev(pos.row, pos.col, this.editor.ui.searchString);
        if (!found) {
            var lastRow = this.model.getRowCount() - 1;
            found = this.model.findPrev(lastRow, this.model.getRowArray(lastRow).length - 1, this.editor.ui.searchString);
        }
        if (found) {
            this.editor.setSelection({startPos: this.cursorManager.getCursorPosition(found.startPos), endPos: this.cursorManager.getCursorPosition(found.endPos)});
            this.cursorManager.moveCursor(this.cursorManager.getCursorPosition(found.endPos));
            this.editor.ui.ensureCursorVisible(true);
            this.repaint();

            return true;
        } else {
            return false;
        }
    },

    // Fire an escape message so various parts of the UI can choose to clear
    escape: function() {
        bespin.publish("ui:escape");
        if (this.editor.ui.searchString) {
            this.editor.ui.setSearchString(false);
        }
    },
    // END SEARCH ACTIONS

    toggleQuickopen: function() {
        var quickopen = bespin.get('quickopen');
        if (quickopen) {
            quickopen.toggle();
        }
    },

    togglePieMenu: function() {
        bespin.getComponent('piemenu', function(piemenu) {
            piemenu.toggle();
        });
    },

    // toggleFilesearch: function() {
    //     var settings = bespin.get("settings");
    // 
    //     var filesearch = bespin.get('filesearch');
    //     if (filesearch) {
    //         filesearch.toggle();
    //     }
    // },

    focusCommandline: function() {
        bespin.getComponent("popup", function(popup) {
            popup.show("output", "Command Line");
        });
    },

    focusFileBrowser: function() {
        bespin.getComponent("popup", function(popup) {
            popup.show("files", "File Explorer");
        });
    },

    repaint: function() {
        if (!this.ignoreRepaints) {
            this.editor.ui.ensureCursorVisible();
            this.editor.paint();
        }
    },

    replace: function(args) {
        this.beginEdit("replace");
        
        this.editor.model.replace(args.search, args.replace);

        this.repaint();
        
        // undo/redo
        this.endEdit();
    },
    
    gotoLine: function() {
        bespin.getComponent("commandLine", function(cli) {
            cli.setCommandText("goto ");
            bespin.getComponent("popup", function(popup) {
                popup.show("output");
            });
        });
    },
    
    cmdFilesearch: function() {
        bespin.getComponent("commandLine", function(cli) {
            cli.setCommandText("search ");
            bespin.getComponent("popup", function(popup) {
                popup.show("output");
            });
        });
    },

    previousFile: function() {
        bespin.get('editSession').goToPreviousFile();
    },

    nextFile: function() {
        bespin.get('editSession').goToNextFile();
    }
 
});

//pretty simple: just create a history edit item, call begin before doing anything, and end after everything is done.
//or manually supply the current states.
dojo.declare("bespin.editor.ActionHistoryItem", null /* pretend it inherits bespin.editor.HistoryItem */, {
    constructor: function(name, editor) {
        this.editor = editor;
    },
    
    begin: function(editor, model)
    {
        this.startIndex = this.editor.historyManager.getCurrent();
        
        if (editor)
            this.editorBefore = editor;
        else
            this.editorBefore = this.editor.getState();
        
        if (model)
            this.modelBefore = model;
        else
            this.modelBefore = this.editor.model.getState();
    },
    
    end: function(editor, model)
    {
        // cheap hack for now. This can stay, but we should _add_ explicit bundling. This will allow multiple
        // levels of detail for undo: you can group all of the "insertCharacter," and then give the user the choice:
        // go character by character, or remove the whole set.
        this.editor.historyManager.truncate(this.startIndex);
        
        if (editor)
            this.editorAfter = editor;
        else
            this.editorAfter = this.editor.getState();
        
        if (model)
            this.modelAfter = model;
        else
            this.modelAfter = this.editor.model.getState();
    },
    
    undo: function()
    {
        this.editor.model.applyState(this.modelBefore);
        this.editor.setState(this.editorBefore);
        this.editor.ui.ensureCursorVisible();
        this.editor.paint();
    },
    
    redo: function()
    {
        this.editor.model.applyState(this.modelAfter);
        this.editor.setState(this.editorAfter);
        this.editor.ui.ensureCursorVisible();
        this.editor.paint();
    }
});


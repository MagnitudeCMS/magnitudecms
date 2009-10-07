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

/**
 * This session module provides functionality that both stores session
 * information and handle collaboration.
 */
dojo.provide("bespin.client.session");

/**
 * EditSession represents a file edit session with the Bespin back-end server.
 * It is responsible for sending changes to the server as well as receiving
 * changes from the server and mutating the document model with received
 * changes.
 */
dojo.declare("bespin.client.session.EditSession", null, {
    constructor: function(editor) {
        this.editor = editor;
        this.currentState = this.mobwriteState.stopped;
        this.bailingOutOfCollaboration = false;
        var self = this;

        this.fileHistory = [];
        this.fileHistoryIndex = -1;

        this.reportCollaborators([]);

        // Take note of in-flight collaboration status changes
        bespin.fireAfter([ "settings:loaded" ], function() {
            bespin.subscribe("settings:set:collaborate", function(ev) {
                if (!window.mobwrite) {
                    // Ignore if there is no mobwrite
                    return;
                }
                if (bespin.get("settings").isOn(ev.value)) {
                    if (self.bailingOutOfCollaboration) {
                        return;
                    }
                    if (editor.dirty) {
                        var msg = "Collaboration enabled on edited file.\n" +
                                "To avoid losing changes, save before collaborating.\n" +
                                "Save now?";
                        var reply = confirm(msg);
                        if (reply) {
                            // User OKed the save
                            var onSuccess = function() {
                                self.startSession(self.project, self.path);
                            };
                            editor.saveFile(self.project, self.path, onSuccess);
                        } else {
                            // Not OK to save, bail out of collaboration
                            self.bailingOutOfCollaboration = true;
                            bespin.get("settings").set("collaborate", "off");
                            self.bailingOutOfCollaboration = false;

                            // We have reset the collaborate setting, but the
                            // output has not yet hit the screen, so we hack the
                            // message somewhat, and show a hint later when the
                            // display has happened. Yuck.
                            var commandLine = bespin.get("commandLine");
                            commandLine.addOutput("Reverting the following collaboration setting:");

                            setTimeout(function() {
                                commandLine.showHint("Collaborate is off");
                            }, 10);
                        }
                    } else {
                        self.startSession(self.project, self.path);
                    }
                } else {
                    self.stopSession();
                    self.setReadOnlyIfNotMyProject(self.project);
                }
            });
        });
    },

    /**
     * Show a hint and set the editor to read-only if we are editing a shared
     * file and collaboration is turned off
     */
    setReadOnlyIfNotMyProject: function(project) {
        if (!bespin.util.isMyProject(project)) {
            bespin.get("editor").setReadOnly(true);
            // This could be run early in the startup process.
            // TODO: bespin.getComponent doesn't work with commandLine for some reason?
            setTimeout(function() {
                var msg = "To edit files in others projects you must have 'collaborate' set to on." +
                          " <a href=\"javascript:bespin.get('settings').set('collaborate', 'on');\">Turn it on now</a>";
                bespin.get("commandLine").showHint(msg, 10000);
            }, 100);
        }
    },

    /**
     * Should we attempt to use collaboration features?
     */
    shouldCollaborate: function() {
        var collab = bespin.get('settings').isSettingOn('collaborate');

        if (collab && !window.mobwrite) {
            console.log("Missing bespin.mobwrite: Forcing 'collaborate' to off in filesystem.js:isCollaborationOn");
            collab = false;
        }

        var capabilities = bespin.get("serverCapabilities");
        if (collab && capabilities.indexOf("collab") == -1) {
            console.log("Server doesn't support collab: Forcing 'collaborate' to off in filesystem.js:isCollaborationOn");
            collab = false;
        }

        return collab;
    },

    /**
     * Opens the previous file within the fileHistoryList related to the
     * current opened file / current position within the fileHistoryList
     * The real opening of the file is done within openFromHistory()
     */
    goToPreviousFile: function() {
        if (this.fileHistoryIndex != 0) {
            this.fileHistoryIndex --;
            this.openFromHistory();
        }
    },

    /**
     * Opens the next file within the fileHistoryList related to the current
     * opened file / current position within the fileHistoryList
     * The real opening of the file is done within openFromHistory()
     */
    goToNextFile: function() {
        if (this.fileHistoryIndex != this.fileHistory.length - 1) {
            this.fileHistoryIndex ++;
            this.openFromHistory();
        }
    },

    /**
     * Opens a file from the fileHistoryList.
     * The file to be opened is set by the variable this.fileHistoryIndex,
     * which is the index for the this.fileHistory array
     */
    openFromHistory: function() {
        var historyItem = this.fileHistory[this.fileHistoryIndex];
        bespin.get("editor").saveFile();
        this.editor.openFile(historyItem.project, historyItem.filename, { fromFileHistory: true });
    },

    /**
     * Adds a new file to the fileHistoryList
     * There are two possible cases:<ul>
     * <li>a) the current opened file is the last one in the fileHistoryList.
     *        If so, just add the file to the end
     * <li>b) the current opened file is *not* at the end of the fileHistoryList.
     *        In this case, we will have to delete the files after the current
     *        one in the list and add then the new one
     * </ul>
     */
    addFileToHistory: function(newItem) {
        this.fileHistoryIndex++;
        var end = this.fileHistory.length - this.fileHistoryIndex;
        this.fileHistory.splice(this.fileHistoryIndex, end, newItem);
    },

    /**
     * Allow us to detect what is going on with mobwrite
     */
    mobwriteState: {
        stopped: 0,
        starting: 1,
        running: 2
    },

    /**
     * Set on login from editor/init.js
     * TODO: Is this is best place for this information?
     */
    setUserinfo: function(userinfo) {
        this.username = userinfo.username;
        this.amountUsed = userinfo.amountUsed;
        this.quota = userinfo.quota;
    },

    /**
     * Is the passed project/path what we are currently working on?
     */
    checkSameFile: function(project, path) {
        return ((this.project == project) && (this.path == path));
    },

    /**
     * Set the current project.
     * TODO: I think we should probably get rid of anywhere this is called
     * because it implies being able to set the project separately from the
     * file being edited.
     */
    setProject: function(project) {
        this.project = project;
    },

    /**
     * Set the current project and path.
     * This method should be used in preference to editSession.setProject(x) or
     * simply editSession.project = x;
     */
    setProjectPath: function(project, path) {
        this.project = project;
        this.path = path;
    },

    /**
     * Begin editing a given project/path hooking up using mobwrite if needed
     * <p>WARNING: If not using mobwrite then the text is loaded somewhere else.
     * (See editor.js:API.newFile|openFile) So there is a lack of symmetry.
     * It's not clear to me if there is a good solution to this
     */
    startSession: function(project, path, onSuccess, onFailure) {
        if (this.currentState == this.mobwriteState.starting) {
            console.warn("Asked to start in the middle of starting. this.shareNode=", this.shareNode);
            onFailure({ responseText: "Can't start callaboration right now" });
            return;
        }

        try {
            var self = this;
            var onUnshared = function() {
                // Remove the current document so we can see that the sync is happening
                self.editor.model.insertDocument("");
                self.editor.moveCursor({ row: 0, col: 0 });
                self.editor.setSelection(null);

                self.editor.setReadOnly(true);

                if (project !== undefined) self.project = project;
                if (path !== undefined) self.path = path;

                self.currentState = self.mobwriteState.starting;

                // Wrap up the onSuccess to clear up after itself
                // TODO: Mobwrite could still fail to load and we would not call
                // onFailure, so we should hook into mobwrite somewhere and push
                // the notification to here. We will need to reset both callbacks
                // when either of them are called
                var onFirstSync = function() {
                    // TODO: ReadOnly state is managed by the server depending on
                    // write access. We need to ensure that this does not clash with
                    // other bits of client side read-only management.
                    self.editor.setReadOnly(false);

                    if (dojo.isFunction(onSuccess)) {
                        onSuccess({
                            name: self.path,
                            timestamp: new Date().getTime()
                        });
                    }

                    self.currentState = self.mobwriteState.running;
                };

                self.shareNode = new bespin.client.session.ShareNode(self, onFirstSync);
                mobwrite.share(self.shareNode);
            };

            // Stop any existing mobwrite session
            if (self.shareNode) {
                self.stopSession(onUnshared, onFailure);
            } else {
                onUnshared();
            }
        } catch (ex) {
            console.trace();
            console.error("startSession error", ex, this);
            onFailure({ responseText: "Failed to start collaboration" });
        }
    },

    /**
     * Stop mobwrite working on a file.
     * <p>This leaves the editor state and mobwrite in whatever state they
     * were in after a final sync.
     */
    stopSession: function(onSuccess, onFailure) {
        // TODO: Something better if we're told to stop while starting?
        if (this.currentState == this.mobwriteState.starting) {
            console.error("Asked to stop in the middle of starting. I can't let you do that Dave.");
            onFailure({ responseText: "Can't stop callaboration right now" });
            return;
        }

        try {
            if (this.currentState == this.mobwriteState.running) {
                mobwrite.unshare([ this.shareNode ], onSuccess);

                // TODO: Should this be set asynchronously when unshare() completes?
                this.currentState = this.mobwriteState.stopped;
                this.shareNode = null;

                this.reportCollaborators([]);
            } else {
                onSuccess();
            }
        } catch (ex) {
            console.error("startSession error", ex, this);
            onFailure({ responseText: "Failed to start collaboration" });
        }
    },

    /**
     * Update the social bar to show the current collaborators.
     * Called by mobwrite/core.js to update the display of collaborators
     * TODO: Perhaps this should be called updateSidebar, however this is
     * called by mobwrite when there is a concept of the collaborators
     * but no concept of the sidebar
     */
    reportCollaborators: function(userEntries) {
        var collabList = dojo.byId("collab_list");

        // Lack of collab_list is likely in the embedded case
        if (!collabList) {
            return;
        }

        var self = this;

        // Collate the entries into a map, one per unique user
        this.users = {};
        this.userCount = 0;
        this.userEntries = userEntries;

        var myId = mobwrite.syncUsername.substring(0,4);

        userEntries.forEach(function(userEntry) {
            userEntry.clientData.cursor = {
                start: self.convertOffsetToRowCol(userEntry.clientData.c.s),
                end: self.convertOffsetToRowCol(userEntry.clientData.c.e)
            };
            delete userEntry.clientData.c;
            userEntry.clientData.isMe = (userEntry.clientData.id == myId);

            var user = self.users[userEntry.handle];
            if (!user) {
                user = {
                    clientDatas: [ userEntry.clientData ],
                    status: ""
                };
                self.users[userEntry.handle] = user;
                self.userCount++;
            } else {
                user.clientDatas.push(userEntry.clientData);
            }
        });

        var maxInLargeMode = 10;

        dojo.empty(collabList);
        for (var username in this.users) {
            if (this.users.hasOwnProperty(username)) {
                var user = this.users[username];
                var extra = "";
                if (user.clientDatas.length > 1) {
                    extra += " <small>(" + user.clientDatas.length + ")</small>";
                }

                var compact = this.userCount > maxInLargeMode;

                var title = user.clientDatas.length + " window" +
                        (user.clientDatas.length > 1 ? "s" : "");
                if (compact) {
                    title += ". Status: " + user.status;
                }

                var parent = dojo.create("div", {
                    style: {
                        // backgroundImage: "url(../images/collab_user_bg.gif)",
                        marginLeft: "10px",
                        height: (compact ? "24px" : "48px")
                    },
                    title: title
                }, collabList);

                var icon = dojo.create("img", {
                    src: "../images/collab_icn_user.png",
                    style: {
                        "float": "left",
                        margin: "4px 8px 0px 8px",
                        height: (compact ? "20px" : "32px"),
                        width: (compact ? "20px" : "32px")
                    }
                }, parent);

                dojo.create("div", {
                    className: 'collab_name',
                    innerHTML: username + extra
                }, parent);

                if (!compact) {
                    dojo.create("div", {
                        className: 'collab_description',
                        innerHTML: user.status
                    }, parent);
                }
            }
        }

        var stopped = (this.currentState === this.mobwriteState.stopped);

        dojo.style("collab_off", "display", stopped ? "block" : "none");
        dojo.style("collab_on",  "display", stopped ? "none" : "block");

        if (stopped) {
            dojo.attr("toolbar_collaboration", "src", "images/icn_collab_off.png");
        } else {
            if (userEntries.length > 1) {
                dojo.attr("toolbar_collaboration", "src", "images/icn_collab_on.png");
            } else {
                dojo.attr("toolbar_collaboration", "src", "images/icn_collab_watching.png");
            }
        }
    },

    /**
     * Allow the editor to paint other users cursors
     */
    getUserEntries: function() {
        return this.userEntries;
    },

    /**
     * Get a textual report on what we are working on
     * TODO: What happens when project == null. Should that ever happen?
     */
    getStatus: function() {
        var file = this.path || 'a new scratch file';
        return 'Hey ' + this.username + ', you are editing ' + file + ' in project ' + this.project;
    },

    /**
     * Convert a row/col cursor position into an offset from file start
     * TODO: We really should have unit tests for these
     * @param {Object} pos an object containing { row: x, col: y } specifiers
     * @return {int} An offset from the start of the document assuming that line
     * feeds are all one char in length
     */
    convertRowColToOffset: function(pos) {
        var offset = 0;
        var rows = this.editor.model.rows;
        for (var i = 0; i < pos.row; i++) {
            if (i >= rows.length) {
                console.warn("Cursor positioned outside the editor document. Assuming end. pos=", pos, "rows.length=", rows.length);
                break;
            }
            offset += rows[i].length + 1; // +1 for LF
        }
        offset += pos.col;
        return offset;
    },

    /**
     * Convert an offset from file start into a row/col cursor position
     * TODO: We really should have unit tests for these
     * @param {int} offset An offset from the start of the document assuming
     * that line feeds are all one char in length
     * @return {Object} an object containing { row: x, col: y } specifiers
     */
    convertOffsetToRowCol: function(offset) {
        var pos = { row: 0, col: 0 };
        var rows = this.editor.model.rows;
        while (true) {
            var len = rows[pos.row].length;
            if (offset <= len) {
                pos.col = offset;
                break;
            }

            offset -= len + 1;
            pos.row += 1;

            if (pos.row >= rows.length) {
                console.warn("convertOffsetToRowCol(", offset, ") has run out of editor characters.");
                pos.row -= 1;
                pos.col = rows[pos.row].length;
                break;
            }
        }
        return pos;
    }
});

/**
 * Mobwrite has a set of shareObjs which are designed to wrap DOM nodes.
 * This creates a fake DOM node to be wrapped in a Mobwrite ShareObj.
 * @param onFirstSync a function to call when the first sync has happened
 * This allows us to support onSuccess. onFirstSync should NOT be null or
 * some of the logic below might break.
 */
dojo.declare("bespin.client.session.ShareNode", null, {
    constructor: function(session, onFirstSync) {
        this.session = session;
        this.editor = session.editor;
        this.onFirstSync = onFirstSync;
        this.username = session.username || "[none]";
        this.errorRaised = false;

        // Create an ID
        var project = session.project;
        var path = session.path;
        if (path.indexOf("/") != 0) {
            path = "/" + path;
        }
        parts = project.split("+");
        if (parts.length == 1) {
            // This is our project
            this.id = this.username + "/" + project + path;
        }
        else {
            // This is someone else's projects
            this.id = parts[0] + "/" + parts[1] + path;
        }
    },

    /**
     * When mobwrite/integrate.js/shareObj is assigned to us it lets us know
     * so that we can share the dmp object.
     */
    setShareObj: function(shareObj) {
        this.shareObj = shareObj;
    },

    /**
     * A way for integrate.js to recognize us
     */
    isShareNode: true,

    /**
     * The session handles the collaborators side-bar
     */
    reportCollaborators: function(userEntries) {
        this.session.reportCollaborators(userEntries);
    },

    /**
     * Something in mobwrite has died. Attempt to tell the user and go into
     * read-only mode if it's fatally broken
     */
    raiseError: function(text, recoverable) {
        text = text || "";
        var prefix = "<strong>" + (recoverable ? "" : "Fatal ") + "Collaboration Error</strong>: ";
        var suffix = "<br/><strong>Warning</strong>: Changes since the last sync could be lost";

        var commandLine = bespin.get("commandLine");
        if (commandLine) {
            commandLine.showHint(prefix + text + suffix, -1);
        } else {
            console.error("Missing commandLine to report: " + text);
        }

        if (!this.errorRaised) {
            this.readOnlyStateBeforeError = this.editor.readonly;
            this.editor.setReadOnly(true);
            this.errorRaised = true;
        }
    },

    /**
     * What is the contents of the editor?
     */
    getClientText: function(allowUnsynced) {
        if (!allowUnsynced && this.onFirstSync) {
            console.trace();
            throw new Error("Attempt to getClientText() before onFirstSync() called.");
        }
        return this.editor.model.getDocument();
    },

    /**
     * Called by mobwrite when it (correctly) assumes that we start blank and
     * that there are therefore no changes to make, however we need call
     * things like onSuccess.
     */
    syncWithoutChange: function() {
        this.syncDone();
    },

    /**
     * Notification used by mobwrite to announce an update.
     * Used by startSession to detect when it is safe to fire onSuccess
     */
    setClientText: function(text) {
        var cursor = this.captureCursor();
        this.editor.model.insertDocument(text);
        this.restoreCursor(cursor);

        this.syncDone();
    },

    /**
     * Set the read-only flag on the editor
     */
    setReadOnly: function(readonly) {
        this.editor.setReadOnly(readonly);
    },

    /**
     * Called by mobwrite to apply patches
     */
    patchClientText: function(patches) {
        // Set some constants which tweak the matching behaviour.
        // Maximum distance to search from expected location.
        this.shareObj.dmp.Match_Distance = 1000;
        // At what point is no match declared (0.0 = perfection, 1.0 = very loose)
        this.shareObj.dmp.Match_Threshold = 0.6;

        var oldClientText = this.getClientText(true);
        var cursor = this.captureCursor();
        // Pack the cursor offsets into an array to be adjusted.
        // See http://neil.fraser.name/writing/cursor/
        var offsets = [];
        if (cursor) {
            offsets[0] = cursor.startOffset;
            if ('endOffset' in cursor) {
                offsets[1] = cursor.endOffset;
            }
        }
        var newClientText = this.patchApply(patches, oldClientText, offsets);
        // Set the new text only if there is a change to be made.
        if (oldClientText != newClientText) {
            this.editor.model.insertDocument(newClientText);
            if (cursor) {
                // Unpack the offset array.
                cursor.startOffset = offsets[0];
                if (offsets.length > 1) {
                    cursor.endOffset = offsets[1];
                    if (cursor.startOffset >= cursor.endOffset) {
                        cursor.collapsed = true;
                    }
                }
                this.restoreCursor(cursor);
            }
        }

        this.syncDone();
    },

    /**
     * Merge a set of patches onto the text.  Return a patched text.
     * This is taken from mobwrite.shareTextareaObj.prototype.patch_apply_
     * and we should find a better way to share. Maybe shareBespinObj should
     * inherit from shareTextareaObj? In the mean time we need to take extra
     * care when doing merges
     * @param {Array.<patch_obj>} patches Array of patch objects.
     * @param {string} text Old text.
     * @param {Array.<number>} offsets Offset indices to adjust.
     * @return {string} New text.
     */
    patchApply: function(patches, text, offsets) {
        if (patches.length == 0) {
            return text;
        }

        // Deep copy the patches so that no changes are made to originals.
        patches = this.shareObj.dmp.patch_deepCopy(patches);
        var nullPadding = this.shareObj.dmp.patch_addPadding(patches);
        text = nullPadding + text + nullPadding;

        this.shareObj.dmp.patch_splitMax(patches);
        // delta keeps track of the offset between the expected and actual location
        // of the previous patch.  If there are patches expected at positions 10 and
        // 20, but the first patch was found at 12, delta is 2 and the second patch
        // has an effective expected position of 22.
        var delta = 0;
        for (var x = 0; x < patches.length; x++) {
            var expected_loc = patches[x].start2 + delta;
            var text1 = this.shareObj.dmp.diff_text1(patches[x].diffs);
            var start_loc = this.shareObj.dmp.match_main(text, text1, expected_loc);
            if (start_loc == -1) {
                // No match found.  :(
                if (mobwrite.debug) {
                    window.console.warn('Patch failed: ' + patches[x]);
                }
            } else {
                // Found a match.  :)
                delta = start_loc - expected_loc;
                var text2 = text.substring(start_loc, start_loc + text1.length);
                // Run a diff to get a framework of equivalent indices.
                var diffs = this.shareObj.dmp.diff_main(text1, text2, false);
                var index1 = 0;
                var index2;
                for (var y = 0; y < patches[x].diffs.length; y++) {
                    var mod = patches[x].diffs[y];
                    if (mod[0] !== DIFF_EQUAL) {
                        index2 = this.shareObj.dmp.diff_xIndex(diffs, index1);
                    }
                    if (mod[0] === DIFF_INSERT) {  // Insertion
                        text = text.substring(0, start_loc + index2) + mod[1] +
                                     text.substring(start_loc + index2);
                        for (var i = 0; i < offsets.length; i++) {
                            if (offsets[i] + nullPadding.length > start_loc + index2) {
                                offsets[i] += mod[1].length;
                            }
                        }
                    } else if (mod[0] === DIFF_DELETE) {  // Deletion
                        var del_start = start_loc + index2;
                        var del_end = start_loc + this.shareObj.dmp.diff_xIndex(diffs,
                                index1 + mod[1].length);
                        text = text.substring(0, del_start) + text.substring(del_end);
                        for (var i = 0; i < offsets.length; i++) {
                            if (offsets[i] + nullPadding.length > del_start) {
                                if (offsets[i] + nullPadding.length < del_end) {
                                    offsets[i] = del_start - nullPadding.length;
                                } else {
                                    offsets[i] -= del_end - del_start;
                                }
                            }
                        }
                    }
                    if (mod[0] !== DIFF_DELETE) {
                        index1 += mod[1].length;
                    }
                }
            }
        }
        // Strip the padding off.
        text = text.substring(nullPadding.length, text.length - nullPadding.length);
        return text;
    },

    /**
     * Nasty hack to allow the editor to know that something has changed.
     * In the first instance the use is restricted to calling the loaded
     * callback
     */
    syncDone: function() {
        if (this.onFirstSync) {
            this.onFirstSync();
            delete this.onFirstSync;
        }

        if (this.errorRaised) {
            if (this.readOnlyStateBeforeError == false) {
                this.editor.setReadOnly(false);
            }
            this.errorRaised = false;

            bespin.get("commandLine").showHint("Connection to server re-established.");
        }
    },

    /**
     * Return cursor information in the meta-data
     */
    getMetaData: function() {
        var cursor = this.captureSimpleCursor();
        var data = { c: { s: cursor.startOffset, e: cursor.endOffset } };
        return dojo.toJson(data);
    },

    /**
     * Record basic information regarding the current cursor.
     * @return {Object?} Context information on the cursor in the format
     * { startOffset:..., endOffset:... }
     * @private
     */
    captureSimpleCursor: function() {
        var selection = this.editor.getSelection();
        var cursor = this.editor.getCursorPos();
        var start = selection ? selection.startPos : cursor;
        var end = selection ? selection.endPos : cursor;

        return {
            startOffset: this.session.convertRowColToOffset(start),
            endOffset: this.session.convertRowColToOffset(end)
        };
    },

    /**
     * Record full information regarding the current cursor.
     * @return {Object?} Context information on the cursor that extends the
     * information from captureSimpleCursor with:
     * { start[Prefix|Suffix]:"...", collapsed:boolean, end[Prefix|Suffix]:"..." }
     * @private
     */
    captureCursor: function() {
        var padLength = this.shareObj.dmp.Match_MaxBits / 2;  // Normally 16.
        var text = this.editor.model.getDocument();

        var cursor = this.captureSimpleCursor();

        cursor.startPrefix = text.substring(cursor.startOffset - padLength, cursor.startOffset);
        cursor.startSuffix = text.substring(cursor.startOffset, cursor.startOffset + padLength);
        cursor.collapsed = (cursor.startOffset == cursor.endOffset);
        if (!cursor.collapsed) {
            cursor.endPrefix = text.substring(cursor.endOffset - padLength, cursor.endOffset);
            cursor.endSuffix = text.substring(cursor.endOffset, cursor.endOffset + padLength);
        }

        var ui = this.editor.ui;
        // HTMLElement.scrollTop = editor.ui.yoffset
        // HTMLElement.scrollHeight = editor.ui.yscrollbar.extent
        // cursor.scroll[Top|Left] are decimals from 0 - 1
        cursor.scrollTop = ui.yoffset / ui.yscrollbar.extent;
        // HTMLElement.scrollLeft = editor.ui.xoffset
        // HTMLElement.scrollWidth = editor.ui.xscrollbar.extent
        cursor.scrollLeft = ui.xoffset / ui.xscrollbar.extent;

        return cursor;
    },

    /**
     * Attempt to restore the cursor's location.
     * @param {Object} cursor Context information of the cursor.
     * @private
     */
    restoreCursor: function(cursor) {
        // TODO: There are 2 ways to optimize this if we need to.
        // The first is to do simple checks like checking the current line is
        // the same before and after insert, and then skipping the whole thing
        // (We perhaps need to do something to avoid duplicate matches like
        // ignoring blank lines or matching 3 lines or similar)
        // OR we could make the restore use row/col positioning rather than
        // offset from start. The latter could be lots of work

        var dmp = this.shareObj.dmp;
        // Set some constants which tweak the matching behavior.
        // Maximum distance to search from expected location.
        dmp.Match_Distance = 1000;
        // At what point is no match declared (0.0 = perfection, 1.0 = very loose)
        dmp.Match_Threshold = 0.9;

        var padLength = dmp.Match_MaxBits / 2; // Normally 16.
        var newText = this.editor.model.getDocument();

        // Find the start of the selection in the new text.
        var pattern1 = cursor.startPrefix + cursor.startSuffix;
        var pattern2, diff;
        var cursorStartPoint = dmp.match_main(newText, pattern1,
                cursor.startOffset - padLength);

        if (cursorStartPoint !== null) {
            pattern2 = newText.substring(cursorStartPoint, cursorStartPoint + pattern1.length);
            //alert(pattern1 + '\nvs\n' + pattern2);
            // Run a diff to get a framework of equivalent indices.
            diff = dmp.diff_main(pattern1, pattern2, false);
            cursorStartPoint += dmp.diff_xIndex(diff, cursor.startPrefix.length);
        }

        var cursorEndPoint = null;
        if (!cursor.collapsed) {
            // Find the end of the selection in the new text.
            pattern1 = cursor.endPrefix + cursor.endSuffix;

            var cursorEndPoint = dmp.match_main(newText, pattern1,
                    cursor.endOffset - padLength);

            if (cursorEndPoint !== null) {
                pattern2 = newText.substring(cursorEndPoint, cursorEndPoint + pattern1.length);
                //alert(pattern1 + '\nvs\n' + pattern2);
                // Run a diff to get a framework of equivalent indices.
                diff = dmp.diff_main(pattern1, pattern2, false);
                cursorEndPoint += dmp.diff_xIndex(diff, cursor.endPrefix.length);
            }
        }

        // Deal with loose ends
        if (cursorStartPoint === null && cursorEndPoint !== null) {
            // Lost the start point of the selection, but we have the end point.
            // Collapse to end point.
            cursorStartPoint = cursorEndPoint;
        } else if (cursorStartPoint === null && cursorEndPoint === null) {
            // Lost both start and end points.
            // Jump to the offset of start.
            cursorStartPoint = cursor.startOffset;
        }
        if (cursorEndPoint === null) {
            // End not known, collapse to start.
            cursorEndPoint = cursorStartPoint;
        }

        // Cursor position
        var startPos = this.session.convertOffsetToRowCol(cursorStartPoint);
        this.editor.moveCursor(startPos);

        // Selection: null means no selection
        var selectionPos = null;
        if (cursorEndPoint != cursorStartPoint) {
            selectionPos = {
                startPos: startPos,
                endPos: this.session.convertOffsetToRowCol(cursorEndPoint)
            };
        }
        this.editor.setSelection(selectionPos);

        // Scroll bars
        var ui = this.editor.ui;
        ui.yscrollbar.setValue(-(cursor.scrollTop * ui.yscrollbar.extent));
        ui.xscrollbar.setValue(-(cursor.scrollLeft * ui.xscrollbar.extent));
    }
});

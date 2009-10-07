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

dojo.provide("bespin.page.editor.dependencies");

dojo.require("bespin.editor.dependencies");

dojo.require("bespin.page.editor.init");

// bespin Server Integration:
dojo.require("bespin.client.filesystem");
dojo.require("bespin.client.settings");
dojo.require("bespin.client.status");
dojo.require("bespin.client.server");
dojo.require("bespin.client.session");

// commands
dojo.require("bespin.cmd.cmd");
dojo.require("bespin.cmd.config");
dojo.require("bespin.cmd.editor");
dojo.require("bespin.cmd.file");
dojo.require("bespin.cmd.other");
dojo.require("bespin.cmd.project");
//dojo.require("bespin.cmd.debug"); // add this to your config to load for yourself

// bespin wizards
dojo.require("bespin.wizard");
dojo.require("bespin.wizardTest");

// bespin social
dojo.require("bespin.social");
dojo.require("bespin.socialTest");


dojo.require("bespin.mobwrite.core");
dojo.require("bespin.mobwrite.diff");
dojo.require("bespin.mobwrite.integrate");

dojo.require("bespin.client.pubsub");

// the preview command...
dojo.require("bespin.preview");

dojo.require("bespin.vcs");
dojo.require("bespin.deploy");


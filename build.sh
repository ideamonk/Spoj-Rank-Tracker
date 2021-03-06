./chrome.manifest                                                                                   0000644 0001750 0001750 00000000466 11213025310 011133                                                                                                                                                                               0000000 0000000                                                                                                                                                                        content	spojranktracker	content/
locale	spojranktracker	en-US	locale/en-US/
skin	spojranktracker	classic/1.0	skin/
overlay	chrome://browser/content/browser.xul	chrome://spojranktracker/content/firefoxOverlay.xul
style	chrome://global/content/customizeToolbar.xul	chrome://spojranktracker/skin/overlay.css
                                                                                                                                                                                                          ./config_build.sh                                                                                   0000644 0001750 0001750 00000000270 11213025310 011077                                                                                                                                                                               0000000 0000000                                                                                                                                                                        #!/bin/bash
# Build config for build.sh
APP_NAME=spojranktracker
CHROME_PROVIDERS="content locale skin"
CLEAN_UP=1
ROOT_FILES=
ROOT_DIRS="defaults"
BEFORE_BUILD=
AFTER_BUILD=
                                                                                                                                                                                                                                                                                                                                        ./content/                                                                                          0000700 0001750 0001750 00000000000 11261146233 007653  5                                                                                                                                                                            0000000 0000000                                                                                                                                                                        ./content/overlay.js~                                                                               0000644 0001750 0001750 00000012262 11170126440 012022                                                                                                                                                                               0000000 0000000                                                                                                                                                                        /* ***** BEGIN LICENSE BLOCK *****
 *   Version: MPL 1.1/GPL 2.0/LGPL 2.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 * 
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is SPOJ Rank Tracker.
 *
 * The Initial Developer of the Original Code is
 * Abhishek Mishra.
 * Portions created by the Initial Developer are Copyright (C) 2009
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *
 * Alternatively, the contents of this file may be used under the terms of
 * either the GNU General Public License Version 2 or later (the "GPL"), or
 * the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
 * in which case the provisions of the GPL or the LGPL are applicable instead
 * of those above. If you wish to allow use of your version of this file only
 * under the terms of either the GPL or the LGPL, and not to allow others to
 * use your version of this file under the terms of the MPL, indicate your
 * decision by deleting the provisions above and replace them with the notice
 * and other provisions required by the GPL or the LGPL. If you do not delete
 * the provisions above, a recipient may use your version of this file under
 * the terms of any one of the MPL, the GPL or the LGPL.
 * 
 * ***** END LICENSE BLOCK ***** */
var oldusername="";
var username="";
var recheck = 2;

var spojranktracker = {	
	// nice lesson from twitterfox source
	$: function(name) {
		return document.getElementById(name);
	},
	onLoad: function() {
		// initialization code
		this.initialized = true;
		this.strings = document.getElementById("spojranktracker-strings");
		
		this.prefs = Components.classes["@mozilla.org/preferences-service;1"]
				.getService(Components.interfaces.nsIPrefService)
				.getBranch("srt.");
				
		setTimeout ('spojranktracker.ShowRank()',1500);
		setInterval ('spojranktracker.MonitorUsername()',1000);
	},
	onToolbarButtonCommand: function(e) {
		// just reuse the function above.  you can change this, obviously!
		spojranktracker.onMenuItemCommand(e);
	},
  
	ShowRank: function(){
		var rank = "0";
		var points = "0";
		var lblRank = spojranktracker.$("SPOJ_rank");
		var lblUser = spojranktracker.$("SPOJ_user");
		var lblPts = spojranktracker.$("SPOJ_pts");
		var lblErr = spojranktracker.$("SPOJ_error");
		
		if (username==""){
			lblRank.setAttribute("value","");
			lblUser.setAttribute("value","");
			lblPts.setAttribute("value","");
			lblErr.setAttribute("value","your spoj username?");
			return;
		}
		
		var req = new XMLHttpRequest();
		req.open('GET', 'http://spoj.pl/users/' + username, true);
		req.onreadystatechange = function (aEvt) {
			lblErr.setAttribute("value","");
			if (req.readyState == 4) {
				if(req.status == 200){
					chunk = req.responseText;
					// test for data
					if (chunk.indexOf("rank:")==-1){
						lblRank.setAttribute("value","");
						lblUser.setAttribute("value",username);
						lblPts.setAttribute("value","");
						lblErr.setAttribute("value","does not exist");
					} else {
						chunk = chunk.split('rank: <a href="/ranks/users/start=')[1].split('</a></b><br><br>\n');
						rank = chunk[0].split('#')[1];
						points = chunk[1].split('</p>')[0];
						lblUser.setAttribute("value",username);
						lblRank.setAttribute("value","#"+ rank);
						lblPts.setAttribute("value",points);
					}
				} else {
					lblRank.setAttribute("value","");
					lblUser.setAttribute("value","");
					lblPts.setAttribute("value","");
					lblErr.setAttribute("value","connection error");
				} 
				
				setTimeout ('spojranktracker.ShowRank()',recheck*1000*60);
			}
		};
		req.send(null);
	},
	
	ShowSettings: function(){
		window.openDialog("chrome://spojranktracker/content/options.xul");
	},
	
	MonitorUsername: function(){
		username = this.prefs.getCharPref("username");
		if (username!=oldusername){
			oldusername = username;
			spojranktracker.ShowRank();
		}
		
		recheck = Number(this.prefs.getCharPref("recheck"));
		if (!recheck || recheck <=0){
			recheck = 2;
			this.prefs.setCharPref("recheck","2");
		}
	},
	
	openSPOJURL: function() {
		url = "http://spoj.pl/users/"+username;
		var tabbrowser = gBrowser;
		var tabs = tabbrowser.tabContainer.childNodes;
		for (var i = 0; i < tabs.length; ++i) {
		  var tab = tabs[i];
		  try {
			var browser = tabbrowser.getBrowserForTab(tab);
			if (browser) {
			  var doc = browser.contentDocument;
			  var loc = doc.location.toString();
			  if (loc == url) {
				gBrowser.selectedTab = tab;
				return;
			  }
			}
		  }
		  catch (e) {
		  }
		}
		
		// There is no tab. open new tab...
		var tab = gBrowser.addTab(url, null, null);
		gBrowser.selectedTab = tab;
	}
};
window.addEventListener("load", function(e) { spojranktracker.onLoad(e); }, false);

                                                                                                                                                                                                                                                                                                                                              ./content/about.xul                                                                                 0000644 0001750 0001750 00000004762 11167213370 011464                                                                                                                                                                               0000000 0000000                                                                                                                                                                        <?xml version="1.0" encoding="UTF-8"?>
<!-- ***** BEGIN LICENSE BLOCK *****
  -   Version: MPL 1.1/GPL 2.0/LGPL 2.1
  -
  - The contents of this file are subject to the Mozilla Public License Version
  - 1.1 (the "License"); you may not use this file except in compliance with
  - the License. You may obtain a copy of the License at
  - http://www.mozilla.org/MPL/
  - 
  - Software distributed under the License is distributed on an "AS IS" basis,
  - WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
  - for the specific language governing rights and limitations under the
  - License.
  -
  - The Original Code is SPOJ Rank Tracker.
  -
  - The Initial Developer of the Original Code is
  - Abhishek Mishra.
  - Portions created by the Initial Developer are Copyright (C) 2009
  - the Initial Developer. All Rights Reserved.
  -
  - Contributor(s):
  -
  - Alternatively, the contents of this file may be used under the terms of
  - either the GNU General Public License Version 2 or later (the "GPL"), or
  - the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
  - in which case the provisions of the GPL or the LGPL are applicable instead
  - of those above. If you wish to allow use of your version of this file only
  - under the terms of either the GPL or the LGPL, and not to allow others to
  - use your version of this file under the terms of the MPL, indicate your
  - decision by deleting the provisions above and replace them with the notice
  - and other provisions required by the GPL or the LGPL. If you do not delete
  - the provisions above, a recipient may use your version of this file under
  - the terms of any one of the MPL, the GPL or the LGPL.
  - 
  - ***** END LICENSE BLOCK ***** -->

<?xml-stylesheet href="chrome://global/skin/" type="text/css"?>
<!DOCTYPE dialog SYSTEM "chrome://spojranktracker/locale/about.dtd">
<dialog title="&about; SPOJ Rank Tracker" orient="vertical" autostretch="always" onload="sizeToContent()" buttons="accept" xmlns="http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul">
<!-- Original template by Jed Brown -->
<groupbox align="center" orient="horizontal">
<vbox>
  <text value="SPOJ Rank Tracker" style="font-weight: bold; font-size: x-large;"/>
  <text value="&version; 1.0"/>
  <separator class="thin"/>
  <text value="&createdBy;" style="font-weight: bold;"/>
  <text value="Abhishek Mishra (ideamonk@gmail.com)"/>
  <separator class="thin"/>
</vbox>
</groupbox>
</dialog>
              ./content/overlay.js                                                                                0000644 0001750 0001750 00000013011 11261146232 011617                                                                                                                                                                               0000000 0000000                                                                                                                                                                        /* ***** BEGIN LICENSE BLOCK *****
 *   Version: MPL 1.1/GPL 2.0/LGPL 2.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 * 
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is SPOJ Rank Tracker.
 *
 * The Initial Developer of the Original Code is
 * Abhishek Mishra.
 * Portions created by the Initial Developer are Copyright (C) 2009
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *
 * Alternatively, the contents of this file may be used under the terms of
 * either the GNU General Public License Version 2 or later (the "GPL"), or
 * the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
 * in which case the provisions of the GPL or the LGPL are applicable instead
 * of those above. If you wish to allow use of your version of this file only
 * under the terms of either the GPL or the LGPL, and not to allow others to
 * use your version of this file under the terms of the MPL, indicate your
 * decision by deleting the provisions above and replace them with the notice
 * and other provisions required by the GPL or the LGPL. If you do not delete
 * the provisions above, a recipient may use your version of this file under
 * the terms of any one of the MPL, the GPL or the LGPL.
 * 
 * ***** END LICENSE BLOCK ***** */
var spojranktracker_oldusername="";
var spojranktracker_username="";
var spojranktracker_recheck = 2;

var spojranktracker = {	
	// nice lesson from twitterfox source
	$: function(name) {
		return document.getElementById(name);
	},

	onLoad: function() {
		// initialization code
		this.initialized = true;
		this.strings = document.getElementById("spojranktracker-strings");
		
		this.prefs = Components.classes["@mozilla.org/preferences-service;1"]
				.getService(Components.interfaces.nsIPrefService)
				.getBranch("srt.");
				
		setTimeout ('spojranktracker.ShowRank()',1500);
		setInterval ('spojranktracker.MonitorUsername()',1000);
	},

	onToolbarButtonCommand: function(e) {
		// just reuse the function above.  you can change this, obviously!
		spojranktracker.onMenuItemCommand(e);
	},
  
	ShowRank: function(){
		var rank = "0";
		var points = "0";
		var lblRank = spojranktracker.$("SPOJ_rank");
		var lblUser = spojranktracker.$("SPOJ_user");
		var lblPts = spojranktracker.$("SPOJ_pts");
		var lblErr = spojranktracker.$("SPOJ_error");
		
		if (spojranktracker_username==""){
			lblRank.setAttribute("value","");
			lblUser.setAttribute("value","");
			lblPts.setAttribute("value","");
			lblErr.setAttribute("value","your spoj username?");
			return;
		}
		
		var req = new XMLHttpRequest();
		req.open('GET', 'http://spoj.pl/users/' + spojranktracker_username, true);
		req.onreadystatechange = function (aEvt) {
			lblErr.setAttribute("value","");
			if (req.readyState == 4) {
				if(req.status == 200){
					chunk = req.responseText;
					// test for data
					if (chunk.indexOf("rank:")==-1){
						lblRank.setAttribute("value","");
						lblUser.setAttribute("value",spojranktracker_username);
						lblPts.setAttribute("value","");
						lblErr.setAttribute("value","does not exist");
					} else {
						chunk = chunk.split('rank: <a href="/ranks/users/start=')[1].split('</a></b><br><br>\n');
						rank = chunk[0].split('#')[1];
						points = chunk[1].split('</p>')[0];
						lblUser.setAttribute("value",spojranktracker_username);
						lblRank.setAttribute("value","#"+ rank);
						lblPts.setAttribute("value",points);
					}
				} else {
					lblRank.setAttribute("value","");
					lblUser.setAttribute("value","");
					lblPts.setAttribute("value","");
					lblErr.setAttribute("value","connection error");
				} 
				
				setTimeout ('spojranktracker.ShowRank()',spojranktracker_recheck*1000*60);
			}
		};
		req.send(null);
	},
	
	ShowSettings: function(){
		window.openDialog("chrome://spojranktracker/content/options.xul");
	},
	
	MonitorUsername: function(){
		spojranktracker_username = this.prefs.getCharPref("username");
		if (spojranktracker_username!=spojranktracker_oldusername){
			spojranktracker_oldusername = spojranktracker_username;
			spojranktracker.ShowRank();
		}
		
		spojranktracker_recheck = Number(this.prefs.getCharPref("recheck"));
		if (!spojranktracker_recheck || spojranktracker_recheck <=0){
			spojranktracker_recheck = 2;
			alert ("Please enter minutes in range 1..99");
			this.prefs.setCharPref("recheck","2");
		}
	},
	
	openSPOJURL: function() {
		url = "http://spoj.pl/users/"+spojranktracker_username;
		var tabbrowser = gBrowser;
		var tabs = tabbrowser.tabContainer.childNodes;
		for (var i = 0; i < tabs.length; ++i) {
		  var tab = tabs[i];
		  try {
			var browser = tabbrowser.getBrowserForTab(tab);
			if (browser) {
			  var doc = browser.contentDocument;
			  var loc = doc.location.toString();
			  if (loc == url) {
				gBrowser.selectedTab = tab;
				return;
			  }
			}
		  }
		  catch (e) {
		  }
		}
		
		// There is no tab. open new tab...
		var tab = gBrowser.addTab(url, null, null);
		gBrowser.selectedTab = tab;
	}
};
window.addEventListener("load", function(e) { spojranktracker.onLoad(e); }, false);

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       ./content/options.xul                                                                               0000644 0001750 0001750 00000001712 11167347010 012034                                                                                                                                                                               0000000 0000000                                                                                                                                                                        <?xml version="1.0"?>
<?xml-stylesheet href="chrome://global/skin/" type="text/css"?>
<?xml-stylesheet href="chrome://spojranktracker/skin/overlay.css" type="text/css"?> 
<prefwindow id="spojranktracker-prefs"
     title="SPOJ Rank Tracker Preferences"
 
     xmlns="http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul">
<prefpane id="srt-userpane" label="Username" oncommand="spojranktracker.Test()">
  <preferences>
    <preference id="pref_symbol" name="srt.username" type="string"/>
	<preference id="pref_symbol2" name="srt.recheck" type="string"/>
  </preferences>
  
  <hbox align="center">
    <label control="symbol" value="SPOJ Username: "/>
    <textbox preference="pref_symbol" id="symbol" maxlength="100" class="pref-user"/>
	<label control="symbol" value="Refresh interval: "/>
    <textbox preference="pref_symbol2" id="symbol2" maxlength="2" class="pref-refresh"/>
	<label control="symbol" value="minutes"/>
  </hbox>
</prefpane>
 
</prefwindow>                                                      ./content/firefoxOverlay.xul                                                                        0000644 0001750 0001750 00000006520 11167361760 013357                                                                                                                                                                               0000000 0000000                                                                                                                                                                        <?xml version="1.0" encoding="UTF-8"?>
<!-- ***** BEGIN LICENSE BLOCK *****
  -   Version: MPL 1.1/GPL 2.0/LGPL 2.1
  -
  - The contents of this file are subject to the Mozilla Public License Version
  - 1.1 (the "License"); you may not use this file except in compliance with
  - the License. You may obtain a copy of the License at
  - http://www.mozilla.org/MPL/
  - 
  - Software distributed under the License is distributed on an "AS IS" basis,
  - WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
  - for the specific language governing rights and limitations under the
  - License.
  -
  - The Original Code is SPOJ Rank Tracker.
  -
  - The Initial Developer of the Original Code is
  - Abhishek Mishra.
  - Portions created by the Initial Developer are Copyright (C) 2009
  - the Initial Developer. All Rights Reserved.
  -
  - Contributor(s):
  -
  - Alternatively, the contents of this file may be used under the terms of
  - either the GNU General Public License Version 2 or later (the "GPL"), or
  - the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
  - in which case the provisions of the GPL or the LGPL are applicable instead
  - of those above. If you wish to allow use of your version of this file only
  - under the terms of either the GPL or the LGPL, and not to allow others to
  - use your version of this file under the terms of the MPL, indicate your
  - decision by deleting the provisions above and replace them with the notice
  - and other provisions required by the GPL or the LGPL. If you do not delete
  - the provisions above, a recipient may use your version of this file under
  - the terms of any one of the MPL, the GPL or the LGPL.
  - 
  - ***** END LICENSE BLOCK ***** -->

<?xml-stylesheet href="chrome://spojranktracker/skin/overlay.css" type="text/css"?>
<!DOCTYPE overlay SYSTEM "chrome://spojranktracker/locale/spojranktracker.dtd">
<overlay id="spojranktracker-overlay"
         xmlns="http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul">
  <script src="overlay.js"/>
  <stringbundleset id="stringbundleset">
    <stringbundle id="spojranktracker-strings" src="chrome://spojranktracker/locale/spojranktracker.properties"/>
  </stringbundleset>

	<statusbar id="status-bar">
		<statusbarpanel id="spoj_button"
		    tooltip="SPOJ Rank Tracker">
			<image src="chrome://spojranktracker/skin/target.png" align="left" style="margin-right:2px;" onclick="spojranktracker.openSPOJURL()" />
			<label id="SPOJ_user" style="margin: 1px" value="" onclick="spojranktracker.ShowSettings()"></label>
			<label id="SPOJ_rank" class="srt-rank" style="margin: 1px" value="SPOJ Rank Tracker" onclick="spojranktracker.ShowSettings()"></label>
			<label id="SPOJ_pts" style="margin: 1px" value="" onclick="spojranktracker.ShowSettings()"></label>
			<label id="SPOJ_error" style="margin: 1px;color:red;font-weight:bold;" value="" onclick="spojranktracker.ShowSettings()"></label>
		</statusbarpanel>
	</statusbar>
	
  <toolbarpalette id="BrowserToolbarPalette">
  <toolbarbutton id="spojranktracker-toolbar-button"
    label="&spojranktrackerToolbar.label;"
    tooltiptext="&spojranktrackerToolbar.tooltip;"
    oncommand="spojranktracker.onToolbarButtonCommand()"
    class="toolbarbutton-1 chromeclass-toolbar-additional"/>
  </toolbarpalette>
</overlay>
                                                                                                                                                                                ./defaults/                                                                                         0000700 0001750 0001750 00000000000 11261141506 010006  5                                                                                                                                                                            0000000 0000000                                                                                                                                                                        ./defaults/preferences/                                                                             0000755 0001750 0001750 00000000000 11261141506 012321  5                                                                                                                                                                            0000000 0000000                                                                                                                                                                        ./defaults/preferences/spojranktracker.js                                                           0000644 0001750 0001750 00000000367 11167345222 016016                                                                                                                                                                               0000000 0000000                                                                                                                                                                        // See http://kb.mozillazine.org/Localize_extension_descriptions
pref("extensions.spojranktracker@abhishek.mishra.description", "chrome://spojranktracker/locale/spojranktracker.properties");
pref("srt.username", "");
pref("srt.recheck", "2");
                                                                                                                                                                                                                                                                         ./install.rdf                                                                                       0000644 0001750 0001750 00000002343 11261144213 010274                                                                                                                                                                               0000000 0000000                                                                                                                                                                        <?xml version="1.0" encoding="UTF-8"?>
<RDF xmlns="http://www.w3.org/1999/02/22-rdf-syntax-ns#" 
 xmlns:em="http://www.mozilla.org/2004/em-rdf#">
  <Description about="urn:mozilla:install-manifest">
    <em:id>spojranktracker@abhishek.mishra</em:id>
    <em:name>SPOJ Rank Tracker</em:name>
    <em:version>1.04</em:version>
    <em:creator>Abhishek Mishra - ideamonk@gmail.com</em:creator>
    <em:description>SPOJ Rank Tracker helps you keep a track of your rank and points you scored on Sphere Online Judge (SPOJ) http://spoj.pl. There are more than 47,000 programmers that compete on SPOJ, the ranks are under constant turbulence. This addon helps you maintain continuity in your SPOJ submissions. All the best, developed by http://ideamonk.blogspot.com , Happy Coding :)</em:description>
	<em:optionsURL>chrome://spojranktracker/content/options.xul</em:optionsURL>
    <em:aboutURL>chrome://spojranktracker/content/about.xul</em:aboutURL>
    <em:targetApplication>
      <Description>
        <em:id>{ec8030f7-c20a-464f-9b0e-13a3a9e97384}</em:id> <!-- firefox -->
        <em:minVersion>1.5</em:minVersion>
        <em:maxVersion>3.5.*</em:maxVersion>
      </Description>
    </em:targetApplication>
  </Description>
</RDF>
                                                                                                                                                                                                                                                                                             ./locale/                                                                                           0000700 0001750 0001750 00000000000 11261141506 007436  5                                                                                                                                                                            0000000 0000000                                                                                                                                                                        ./locale/en-US/                                                                                     0000755 0001750 0001750 00000000000 11261141506 010377  5                                                                                                                                                                            0000000 0000000                                                                                                                                                                        ./locale/en-US/spojranktracker.dtd                                                                  0000644 0001750 0001750 00000000302 11167362700 014220                                                                                                                                                                               0000000 0000000                                                                                                                                                                        <!ENTITY spojranktracker.label "Your localized menuitem">
<!ENTITY spojranktrackerToolbar.label "Your Toolbar Button">
<!ENTITY spojranktrackerToolbar.tooltip "This is your toolbar button!">
                                                                                                                                                                                                                                                                                                                              ./locale/en-US/spojranktracker.properties                                                           0000644 0001750 0001750 00000000643 11167362772 015662                                                                                                                                                                               0000000 0000000                                                                                                                                                                        prefMessage=Int Pref Value: %d
extensions.spojranktracker.description=SPOJ Rank Tracker helps you keep a track of your rank and points you scored on Sphere Online Judge (SPOJ) http://spoj.pl. There are more than 47,000 programmers that compete on SPOJ, the ranks are under constant turbulence. This addon helps you maintain continuity in your SPOJ submissions. All the best, developed by http://ideamonk.blogspot.com
                                                                                             ./locale/en-US/about.dtd                                                                            0000644 0001750 0001750 00000000254 11167362630 012137                                                                                                                                                                               0000000 0000000                                                                                                                                                                        <!ENTITY about "About">
<!ENTITY version "Version: 1.0">
<!ENTITY createdBy "Created By: Abhishek Mishra">
<!ENTITY homepage "Home Page: http://ideamonk.blogspot.com">
                                                                                                                                                                                                                                                                                                                                                    ./readme.txt                                                                                        0000644 0001750 0001750 00000003116 11261142565 010136                                                                                                                                                                               0000000 0000000                                                                                                                                                                        SPOJ Rank Tracker helps you keep a track of your live rank and points you score,
in a way it keeps you motivated. There are more than 47,000 programmers that 
compete on SPOJ, the ranks are under constant turbulence. (APR 09 2009)
This add-on helps you maintain continuity in your SPOJ submissions.

Features -
* Track any user on SPOJ
* Set Refresh Intervals to minimize bandwidth wastage
* Tested on Linux and Windows

Usage -
* Click SPOJ icon to goto the user's spoj Profile
* Click anywhere else on the addon to setup username and refresh interval

--------------------------------------------------------------------------------


This extension was generated by the Extension Wizard at
http://ted.mielczarek.org/code/mozilla/extensionwiz/ .
This extension is compatible only with Firefox 1.5 and
above.  Most of the files in this package are based on
the 'helloworld' extension from the Mozillazine Knowledge Base.

You can build an XPI for installation by running the
build.sh script located in this folder.  For development
you should do the following:
  1. Unzip the entire contents of this package to somewhere,
	       e.g, c:\dev or /home/user/dev
  2. Put the full path to the folder (e.g. c:\dev\spojranktracker on
     Windows, /home/user/dev/spojranktracker on Linux) in a file named
     spojranktracker@abhishek.mishra and copy that file to
     [your profile folder]\extensions\
  3. Restart Firefox.

For more information, see the Mozillazine Knowledge Base:
http://kb.mozillazine.org/Getting_started_with_extension_development

-Ted Mielczarek <ted.mielczarek@gmail.com>
                                                                                                                                                                                                                                                                                                                                                                                                                                                  ./readme.txt~                                                                                       0000644 0001750 0001750 00000001721 11213025310 010315                                                                                                                                                                               0000000 0000000                                                                                                                                                                        This extension was generated by the Extension Wizard at
http://ted.mielczarek.org/code/mozilla/extensionwiz/ .
This extension is compatible only with Firefox 1.5 and
above.  Most of the files in this package are based on
the 'helloworld' extension from the Mozillazine Knowledge Base.

You can build an XPI for installation by running the
build.sh script located in this folder.  For development
you should do the following:
  1. Unzip the entire contents of this package to somewhere,
	       e.g, c:\dev or /home/user/dev
  2. Put the full path to the folder (e.g. c:\dev\spojranktracker on
     Windows, /home/user/dev/spojranktracker on Linux) in a file named
     spojranktracker@abhishek.mishra and copy that file to
     [your profile folder]\extensions\
  3. Restart Firefox.

For more information, see the Mozillazine Knowledge Base:
http://kb.mozillazine.org/Getting_started_with_extension_development

-Ted Mielczarek <ted.mielczarek@gmail.com>
                                               ./skin/                                                                                             0000700 0001750 0001750 00000000000 11261141506 007143  5                                                                                                                                                                            0000000 0000000                                                                                                                                                                        ./skin/overlay.css                                                                                  0000644 0001750 0001750 00000001307 11167346340 011301                                                                                                                                                                               0000000 0000000                                                                                                                                                                        /* This is just an example.  You shouldn't do this. */
/*
#spojranktracker-hello
{
  color: red ! important;
}
#spojranktracker-toolbar-button
{
  list-style-image: url("chrome://spojranktracker/skin/toolbar-button.png");
  -moz-image-region: rect(0px 24px 24px 0px);
}
#spojranktracker-toolbar-button:hover
{
  -moz-image-region: rect(24px 24px 48px  0px);
}
[iconsize="small"] #spojranktracker-toolbar-button
{
  -moz-image-region: rect( 0px 40px 16px 24px);
}
[iconsize="small"] #spojranktracker-toolbar-button:hover
{
  -moz-image-region: rect(24px 40px 40px 24px);
}
*/
.srt-rank{
	color:green;
	font-weight:bold;
}
.pref-refresh{
	width:30px;
}
.pref-user{
	width:100px;
}                                                                                                                                                                                                                                                                                                                         ./skin/target.png                                                                                   0000644 0001750 0001750 00000001750 11167355442 011107                                                                                                                                                                               0000000 0000000                                                                                                                                                                        �PNG

   IHDR         ��a  �IDATx�USP�e~^`��ǘ(Ɨ�L6�����.��1J�������ITB(�8�Z������UJ�Y�.�L�$�����4d��d�}�ʝ\}�z�}��}�y��!���\��ϴ�T�D�FːN��H2�D��Q�{4�j�Y&I�=�C�,�:ޝ
��z�)�8��<�(�����0�X��R��q5/���?p�ͮ|�u��E��G�B�;�\6��̺Wp�wMg�"[.�	���e}����d5��NSA�c#VWW1b�������=)��F 6���^'�z+�d;*Ԓ"RR����)�Q�A6

�yq�v�j���Ǉ� �>�~Z<��ʎ֖Q��R�әh���݈O$���n������,�������b��j)�ң�Z���o(-��(�:�J5�_a�Y��؍�l�JgL�@jjlw�%� .��M��A�"�b���
�U<Ř���o�]ݏK�:���1K�qX�4��M`�"�C8��LW\ �̳�;�Y(WS�I����\��B��?a���Z��U�g�������~�:���A����c�a�~
q	�56�w��ߨA�/nt~���W� ��׽;�#��������i����AK��C�o؉�i�,��i+��m8��s�S��X��� ��w�T�/�ߟ5����B�O��A[�99Q^������9���T���"6���/&�i�T{���]��e��l~@�5ȱ]�C8!p��q��g�Jc[V�l����'��q��.GYyf�Z��;ѓ��i�?z$>�݆gv^r$���4����+���q���J˶j�������V�܌���%%Ƭ��x, D0�^��y�}!Tiv8�B�f_���m|<7��~WdJ6ͷ�03�� �	P*�i���1�q�u�d�w�����    IEND�B`�                        ./skin/Thumbs.db                                                                                    0000644 0001750 0001750 00000017000 11167357030 010652                                                                                                                                                                               0000000 0000000                                                                                                                                                                        ��ࡱ�                >  ��	                               ����        ����������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������   ����            	   ����
            ����������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������R o o t   E n t r y                                               ��������                               ������   �      1                                                                ������������                                        �      C a t a l o g                                                     ������������                                       �       2                                                                      ����                                       S                              	   
                                          ����   H                      !   "   #   $   %   &   '   ����)   *   +   ,   -   .   /   0   1   2   3   4   5   6   7   8   9   :   ����<   =   >   ?   @   A   B   C   D   E   F   G   ����I   ����������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������      �  ���� JFIF  ` `  �� C 


�� C		��  0 (" ��           	
�� �   } !1AQa"q2���#B��R��$3br�	
%&'()*456789:CDEFGHIJSTUVWXYZcdefghijstuvwxyz���������������������������������������������������������������������������        	
�� �  w !1AQaq"2�B����	#3R�br�
$4�%�&'()*56789:CDEFGHIJSTUVWXYZcdefghijstuvwxyz��������������������������������������������������������������������������   ? �S��?��� �������3�n;~�zV޵���\��~�wE�@ڤw<uj�����/����+O�����ϛ������Ͻ}�W�S���hK�������zin���qV���a�Ö�^�.k_E���G�x�?�
��g�:��Q>��(��Ń� �g �#����w0���]�p\.���=���<#m���7Zw���S�*U���A#$�kȣ��a14�Z�wj܏E�ں>����:�EҲ��H�ڷ����W�gǏY|3����(�UH�KG#0b�@$)�U��� <#s����Z����S0�6VܮY]�'s�(�\k��D��}U���vX����>�I_e���W���A� 7� 	�%� �g�����!�����q�c�}__�Iq� �����<����^a���zWNM��ϳkJR��i����N����M�����׺zw��gڴQ_<|���/���Xx��� !�c�\�u8_c^N	WUS����7k�g������u*�'f�m+�^����W� ?h?E��V�%�uu���h�g]��QZb08�=YS������e�̰��Q��F�&�2���g!��������z��0���>��:�ھ\� ��o�4/�~�����gھи�� ��_�5�/�*��T� �M�������}��o/fq�8��_e��J��R�8ڜ��v�d�ߪ�|.s�:�T�>z�N�r�N���ݷGГ@��չ�5���WS MN>W<�#�w?>x1~x��O�ͨռ�a�C4�˨��<�k�h���mZu�Z1�9zAr���������S�R��)��Y�w�{���/�<�
�5u�xf���A3N��B��d��xW��\�]lEYT����ޗ=<6��iFD�쵲����               `   `   8       �8����t o o l b a r - b u t t o n . p n g     (       *����t a r g e t . p n g     @       �2~��      G  ���� JFIF  ` `  �� C 


�� C		��   " ��           	
�� �   } !1AQa"q2���#B��R��$3br�	
%&'()*456789:CDEFGHIJSTUVWXYZcdefghijstuvwxyz���������������������������������������������������������������������������        	
�� �  w !1AQaq"2�B����	#3R�br�
$4�%�&'()*56789:CDEFGHIJSTUVWXYZcdefghijstuvwxyz��������������������������������������������������������������������������   ? ��?��c�>�����kþ)֗O����SHѬX�˫��� Z��;��P@�=G�o��o�n~"x3�V>ӵ��3G��I�������yc2�s�YNx!5Ho>�i�E�7��I�R��T�^� I���3����q,Y,v���O�+^�|C�o��o�9�uu�V����IӭABm-�#8�.W��'-}N�=yo����MGշ�g6�?�٢�ű��^�S���éU�[��{_��kF���� ��z�χ�����3                                                                 ������������                                    (   �      4                                                                      ����                                    ;   @                                                                          ������������                                                                                                                    ������������                                                      u  ���� JFIF  ` `  �� C 


�� C		��   " ��           	
�� �   } !1AQa"q2���#B��R��$3br�	
%&'()*456789:CDEFGHIJSTUVWXYZcdefghijstuvwxyz���������������������������������������������������������������������������        	
�� �  w !1AQaq"2�B����	#3R�br�
$4�%�&'()*56789:CDEFGHIJSTUVWXYZcdefghijstuvwxyz��������������������������������������������������������������������������   ? ��->%x;ƿ|u�k:W��]�a��>�{i�D�M�w��X�]�y�qEz���𵮷�[_xO�|G�;Y/t�x[Z�M�2D%�#2yr���F��6�8&��l�}��s���>������G�l �k���-�i�A���Gppr3X~j� i�	�S��'���}M�r�='��cy���lQ� �~T���'V�&���ʵ�q�t������jwI4sn����� �-S@�t��Wz~���h��!��.eDI� �>T�K�F�E|ů~Ϻ��e��^?�����?�,n^FT���A-�eA�d��#���8	�*չ$�n6�[Wk��tإ)�W>����i�c�|J��-S�9Ҭ�5�
T��b_��r#�<`���J� 	�'������>"��1����r�Y�Ӵo���� �<�B��a�U2	�+��(ӫ�J�H�8�ͫ�m��V�c9�N����i��,t}�7J��m�l�$pƣ
��� QE|m�����                                                                     4  ���� JFIF  ` `  �� C 


�� C		��   " ��           	
�� �   } !1AQa"q2���#B��R��$3br�	
%&'()*456789:CDEFGHIJSTUVWXYZcdefghijstuvwxyz���������������������������������������������������������������������������        	
�� �  w !1AQaq"2�B����	#3R�br�
$4�%�&'()*56789:CDEFGHIJSTUVWXYZcdefghijstuvwxyz��������������������������������������������������������������������������   ? �� �/�����{��t�s=�M䢄d�I�*,h�s��χ�"�%�x/�S�o�~E���#	7�rG!Ub��teq�X�����]Lݛ2msJ����Qs�:�ʒBY|ȟˍ�F��xg����TӾ���.mI��b��kQm�FEp�chd��v.���?.�b����+�ۼ��� ���p�ϟ����[�����C o p y   ( 2 )   o f   t a r g e t . p n g     8       L7k	��C o p y   o f   t a r g e t . p n g                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
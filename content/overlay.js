/* ***** BEGIN LICENSE BLOCK *****
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


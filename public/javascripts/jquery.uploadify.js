/*
Uploadify v2.0.0

Copyright (c) 2009 Ronnie Garcia, Travis Nickels

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

if(jQuery){(function(a){a.extend(a.fn,{uploadify:function(b){a(this).each(function(){settings=a.extend({id:a(this).attr("id"),uploader:"uploadify.swf",script:"uploadify.php",expressInstall:null,folder:"",height:30,width:110,cancelImg:"cancel.png",wmode:"opaque",scriptAccess:"sameDomain",fileDataName:"Filedata",method:"POST",queueSizeLimit:999,simUploadLimit:1,queueID:false,displayData:"percentage",onInit:function(){},onSelect:function(){},onQueueFull:function(){},onCheck:function(){},onCancel:function(){},onError:function(){},onProgress:function(){},onComplete:function(){},onAllComplete:function(){}},b);var e=location.pathname;e=e.split("/");e.pop();e=e.join("/")+"/";var f={};f.uploadifyID=settings.id;f.pagepath=e;if(settings.buttonImg){f.buttonImg=escape(settings.buttonImg)}if(settings.buttonText){f.buttonText=escape(settings.buttonText)}if(settings.rollover){f.rollover=true}f.script=settings.script;f.folder=escape(settings.folder);if(settings.scriptData){var g="";for(var d in settings.scriptData){g+="&"+d+"="+settings.scriptData[d]}f.scriptData=escape(g.substr(1))}f.width=settings.width;f.height=settings.height;f.wmode=settings.wmode;f.method=settings.method;f.queueSizeLimit=settings.queueSizeLimit;f.simUploadLimit=settings.simUploadLimit;if(settings.hideButton){f.hideButton=true}if(settings.fileDesc){f.fileDesc=settings.fileDesc}if(settings.fileExt){f.fileExt=settings.fileExt}if(settings.multi){f.multi=true}if(settings.auto){f.auto=true}if(settings.sizeLimit){f.sizeLimit=settings.sizeLimit}if(settings.checkScript){f.checkScript=settings.checkScript}if(settings.fileDataName){f.fileDataName=settings.fileDataName}if(settings.queueID){f.queueID=settings.queueID}if(settings.onInit()!==false){a(this).css("display","none");a(this).after('<div id="'+a(this).attr("id")+'Uploader"></div>');swfobject.embedSWF(settings.uploader,settings.id+"Uploader",settings.width,settings.height,"9.0.24",settings.expressInstall,f,{quality:"high",wmode:settings.wmode,allowScriptAccess:settings.scriptAccess});if(settings.queueID==false){a("#"+a(this).attr("id")+"Uploader").after('<div id="'+a(this).attr("id")+'Queue" class="uploadifyQueue"></div>')}}a(this).bind("uploadifySelect",{action:settings.onSelect,queueID:settings.queueID},function(j,h,i){if(j.data.action(j,h,i)!==false){var k=Math.round(i.size/1024*100)*0.01;var l="KB";if(k>1000){k=Math.round(k*0.001*100)*0.01;l="MB"}var m=k.toString().split(".");if(m.length>1){k=m[0]+"."+m[1].substr(0,2)}else{k=m[0]}if(i.name.length>20){fileName=i.name.substr(0,20)+"..."}else{fileName=i.name}queue="#"+a(this).attr("id")+"Queue";if(j.data.queueID){queue="#"+j.data.queueID}a(queue).append('<div id="'+a(this).attr("id")+h+'" class="uploadifyQueueItem"><div class="cancel"><a href="javascript:jQuery(\'#'+a(this).attr("id")+"').uploadifyCancel('"+h+'\')"><img src="'+settings.cancelImg+'" border="0" /></a></div><span class="fileName">'+fileName+" ("+k+l+')</span><span class="percentage"></span><div class="uploadifyProgress"><div id="'+a(this).attr("id")+h+'ProgressBar" class="uploadifyProgressBar"><!--Progress Bar--></div></div></div>')}});if(typeof(settings.onSelectOnce)=="function"){a(this).bind("uploadifySelectOnce",settings.onSelectOnce)}a(this).bind("uploadifyQueueFull",{action:settings.onQueueFull},function(h,i){if(h.data.action(h,i)!==false){alert("The queue is full.  The max size is "+i+".")}});a(this).bind("uploadifyCheckExist",{action:settings.onCheck},function(m,l,k,j,o){var i=new Object();i=k;i.folder=e+j;if(o){for(var h in k){var n=h}}a.post(l,i,function(r){for(var p in r){if(m.data.action(m,l,k,j,o)!==false){var q=confirm("Do you want to replace the file "+r[p]+"?");if(!q){document.getElementById(a(m.target).attr("id")+"Uploader").cancelFileUpload(p,true)}}}if(o){document.getElementById(a(m.target).attr("id")+"Uploader").startFileUpload(n,true)}else{document.getElementById(a(m.target).attr("id")+"Uploader").startFileUpload(null,true)}},"json")});a(this).bind("uploadifyCancel",{action:settings.onCancel},function(l,h,k,m,j){if(l.data.action(l,h,k,m,j)!==false){var i=(j==true)?0:250;a("#"+a(this).attr("id")+h).fadeOut(i,function(){a(this).remove()})}});if(typeof(settings.onClearQueue)=="function"){a(this).bind("uploadifyClearQueue",settings.onClearQueue)}var c=[];a(this).bind("uploadifyError",{action:settings.onError},function(l,h,k,j){if(l.data.action(l,h,k,j)!==false){var i=new Array(h,k,j);c.push(i);a("#"+a(this).attr("id")+h+" .percentage").text(" - "+j.type+" Error");a("#"+a(this).attr("id")+h).addClass("uploadifyError")}});a(this).bind("uploadifyProgress",{action:settings.onProgress,toDisplay:settings.displayData},function(j,h,i,k){if(j.data.action(j,h,i,k)!==false){a("#"+a(this).attr("id")+h+"ProgressBar").css("width",k.percentage+"%");if(j.data.toDisplay=="percentage"){displayData=" - "+k.percentage+"%"}if(j.data.toDisplay=="speed"){displayData=" - "+k.speed+"KB/s"}if(j.data.toDisplay==null){displayData=" "}a("#"+a(this).attr("id")+h+" .percentage").text(displayData)}});a(this).bind("uploadifyComplete",{action:settings.onComplete},function(k,h,j,i,l){if(k.data.action(k,h,j,unescape(i),l)!==false){a("#"+a(this).attr("id")+h+" .percentage").text(" - Completed");a("#"+a(this).attr("id")+h).fadeOut(250,function(){a(this).remove()})}});if(typeof(settings.onAllComplete)=="function"){a(this).bind("uploadifyAllComplete",{action:settings.onAllComplete},function(h,i){if(h.data.action(h,i)!==false){c=[]}})}})},uploadifySettings:function(f,j,c){var g=false;a(this).each(function(){if(f=="scriptData"&&j!=null){if(c){var i=j}else{var i=a.extend(settings.scriptData,j)}var l="";for(var k in i){l+="&"+k+"="+escape(i[k])}j=l.substr(1)}g=document.getElementById(a(this).attr("id")+"Uploader").updateSettings(f,j)});if(j==null){if(f=="scriptData"){var b=unescape(g).split("&");var e=new Object();for(var d=0;d<b.length;d++){var h=b[d].split("=");e[h[0]]=h[1]}g=e}return g}},uploadifyUpload:function(b){a(this).each(function(){document.getElementById(a(this).attr("id")+"Uploader").startFileUpload(b,false)})},uploadifyCancel:function(b){a(this).each(function(){document.getElementById(a(this).attr("id")+"Uploader").cancelFileUpload(b,true,false)})},uploadifyClearQueue:function(){a(this).each(function(){document.getElementById(a(this).attr("id")+"Uploader").clearFileUploadQueue(false)})}})})(jQuery)};
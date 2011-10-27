//--------------------------------------
// Expects input fields with IDs "diagram_white" and "diagram_black" with English notation
// Depends upon jQuery
//
// Iļja Ketris (c) 2008-2011
//
google.setOnLoadCallback(function(){function a(){aBoard=[];for(i=0;i<8;++i)aBoard.push(arrayOfOnes.slice(0))}function b(){boobs=/^\[(.)(.+)\]/,allPieces=["wk","wq","wr","wb","ws","wp","bk","bq","br","bb","bs","bp","xwk","xwq","xwr","xwb","xws","xwp","xbk","xbq","xbr","xbb","xbs","xbp"],aPieces={},imgPieces={},$.each(allPieces,function(a,b){aPieces[b]=$.globals.fig_path+b+".gif",imgPieces[b]=$("<img>").attr("src",aPieces[b])})}function c(){var a=fp=0,b="",c=[],d=$("#diagram_position").val();d=d.replace(/\d+/g,function(a){return"1".times(Number(a))}),$.each(d.split(""),function(d,e){switch(e){case"[":b="[",a=1;break;case"(":fp=2,b="(";break;case"]":c.push(b+"]"),b="",a=fp=0;break;case")":b+=")",fp=0;break;case"/":c=c.concat("1".times((8-c.length%8)%8).split(""));break;default:switch(a+fp){case 0:b.length&&(c.push(b),b=""),c.push(e.n2s());break;default:b+=e}}}),eight.each(function(a,b){aBoard[a]=c.slice(a*8,a*8+8)})}function d(){var b,c,d;a(),$(["#diagram_white","#diagram_black","#white_c","#black_c"]).each(function(a,e){$($(e).val().toLowerCase().split(/\W/)).each(function(e,f){f.length==2&&(f="p"+f);if(f.length!=3)return;f=f.toLowerCase(),piece=f.charAt(0),file=f.charCodeAt(1),rank=f.charAt(2);if(file<97||file>104)return;if(rank<"1"||rank>"8")return;if("kdtlsp".indexOf(piece)<0)return;switch(!0){case a>1:b="[x",c="]";break;default:b=c=""}d=a%2==0?function(a){return a.toUpperCase()}:idem,aBoard[8-rank][file-97]=b+d(nEngl.charAt(nFide.indexOf(piece)))+c})})}function e(){var a,b,c,d,e,h,i="";for(var j=0;j<8;++j)for(var k=0;k<8;++k){a=aBoard[j][k];if(a=="1"){$('.pieceOnBoard[data-x="'+j+'"][data-y="'+k+'"]').remove();continue}h=a.match(boobs),h?(a=h[2],gf_cond="x"):gf_cond="",e=a>"a"?"b":"w",d=k*25+1,c=j*25+1,a=a.n2s(),b=imgPieces[gf_cond+e+a.toLowerCase()].clone(),$("#divBlank").append(b),$('.pieceOnBoard[data-x="'+j+'"][data-y="'+k+'"]').remove(),b.css({position:"absolute",top:c+"px",left:d+"px"}).attr("data-x",j).attr("data-y",k).data("id",a).addClass("pieceOnBoard ui-draggable").draggable({revert:!1,zIndex:5,stop:function(a,b){var c=$(this);aBoard[c.data("x")][c.data("y")]="1",g(),f(),c.remove()}})}var l=aBoard.join("").match(/[a-z]/g),m=aBoard.join("").match(/[A-Z]/g);$("#pcount").html("("+(m?m.length:"0")+" + "+(l?l.length:"0")+")")}function f(){$("#diagram_position").val(aBoard.join("/").replace(/,/g,"").replace(/s/g,"n").replace(/S/g,"N").replace(/\d+/g,function(a){return a.length}))}function g(){var a,b,c,d,e={diagram_white:[],diagram_black:[],white_c:[],black_c:[]};for(var f=0;f<8;++f)for(var g=0;g<8;++g){a=aBoard[f][g],b=a.match(boobs),b?(c=!0,a=b[2]):c=!1;if(a!=="1"){switch(!0){case!c&&a.isWhite():d="diagram_white";break;case!c&&!a.isWhite():d="diagram_black";break;case c&&a.isWhite():d="white_c";break;case c&&!a.isWhite():d="black_c"}e[d].push(notationFIDE.substr(notationEnglish.indexOf(a),1)+String.fromCharCode(g+97)+(8-f).toString())}}for(x in e)$("#"+x).val(e[x].sort(l).join(" "))}function h(){return $("diagram_stipulation").value.length<2?(new Effect.Highlight("diagram_stipulation",{startcolor:"ffffee",transition:Effect.Transitions.linear,duration:2}),new Effect.Pulsate("diagram_stipulation",{duration:2}),$("diagram_stipulation").focus(),!1):!0}function j(a){return a.keyCode<32||a.keyCode>58?!1:(d(),e(),f(),!0)}function k(a){return c(),e(),g(),!0}function l(a,b){var c;if(c=a.match(boobs))a=c[2];if(c=b.match(boobs))b=c[2];var d="KDTLSp";return d.indexOf(a.substr(0,1))-d.indexOf(b.substr(0,1))}function m(){$("#showfairy").hide(),$("#fairy").show()}function n(a){var b=[],c="";$("#twin").val(""),$("#twn").val(toLowerCase().split(/.\)|\.|\,/).each(function(a,d){if(d.length<3)return;switch(!0){case b=d.match(/(\w\w)-?>(\w\w)/),b!=null:c="Move "+b[1]+" "+b[2];break;case b=d.match(/\+(\w)(\w)(\w\w)/),b!=null:c="Add "+(b[1]=="w"?"White ":"Black ")+b[2]+b[3];break;case b=d.match(/\-(\w)(\w)(\w\w)/),b!=null:c="Remove "+(b[1]=="w"?"White ":"Black ")+b[2]+b[3];break;case b=d.match(/\w*(\w\w)<.*>\w*(\w\w)/),b!=null:c="Exchange "+b[1]+" "+b[2];break;default:return}$("#twin").attr("value",$("#twin").attr("value")+("Twin "+c+"\n"))}))}function o(){e(),g(),f()}$("#fen_button").click(function(a){$("#fen-block").toggle(),a.preventDefault()}),$("#fairy_button").click(function(a){$("#fairy-block").toggle(),a.preventDefault()}),$("#solve").click(function(a){var b=$("form");$("#solve").val(" Solving... "),$.post("/diagrams/solve",{stipulation:$("#diagram_stipulation").val(),position:$("#diagram_position").val()},function(a){$("#solution").html(a),$("#solve").val("Finished.  Solve again.")}),a.preventDefault()}),$("#authors_ids").tokenInput("/authors/json",{hintText:"Start typing author's name or handle",minChars:3,prePopulate:$.parseJSON($("#authors_json").val()),theme:"facebook",onBeforeAdd:function(a){var b;isNaN(a.id)&&(b=a.id.match(/^CREATE_(.+?)$/))&&(a.name=b[1])}}),aBoard=[],arrayOfOnes=["1","1","1","1","1","1","1","1"],eight=$(arrayOfOnes),notationEnglish="KQRBSPkqrbsp",notationFIDE="KDTLSpKDTLSp",nEngl="kqrbsp",nFide="kdtlsp",$("#diagram_white").bind("keyup",j),$("#diagram_black").bind("keyup",j),$("#diagram_position").bind("keyup",k),$("#white_c").bind("keyup",j),$("#black_c").bind("keyup",j),b(),$("#diagram_position").val()?k():j({keyCode:50}),$("#diagram_white").focus(),$(".todrag").draggable({revertDuration:0,revert:!0,cursor:"crosshair",zIndex:5}),$("#blank").droppable({drop:function(a,b){var c=$("#blank").offset(),d=b.draggable;aBoard[Math.floor((b.offset.top-c.top+12)/25)][Math.floor((b.offset.left-c.left+12)/25)]=d.data("id"),d.hasClass("pieceOnBoard")&&(aBoard[d.data("x")][d.data("y")]="1",d.remove()),o()}}),$(".moveboard").button(),$(".moveboard").click(function(){switch($(this).data("name")){case"▷":$.each(aBoard,function(a,b){b.unshift("1"),b.pop()});break;case"◁":$.each(aBoard,function(a,b){b.shift(),b.push("1")});break;case"△":aBoard.shift(),aBoard.push(arrayOfOnes);break;case"▽":aBoard.pop(),aBoard.unshift(arrayOfOnes);break;case"↺":newBoard=[],eight.each(function(){newBoard.push(arrayOfOnes.slice(0))}),eight.each(function(a,b){eight.each(function(b,c){newBoard[7-b][a]=aBoard[a][b]})}),aBoard=newBoard;break;case"↻":newBoard=[],eight.each(function(){newBoard.push(arrayOfOnes.slice(0))}),eight.each(function(a,b){eight.each(function(b,c){newBoard[b][7-a]=aBoard[a][b]})}),aBoard=newBoard;break;case"↕":aBoard.reverse()}return o(),!1})})
// Copyright(C) by Marek Kwiatkowski; Some changes of this file are prohibited !

var Dg=new Array();
var Nd=-1;
var Tph='t/';
var Piece=new Array();
var NPiece=new Array('_','p','bp','r','br','s','bs','b','bb','q','bq','k','bk','g','bg','n','bn');
for (i=0;i<17;i++)
{Piece[i]=new Image();
Piece[i].src=Tph+NPiece[i]+'.gif'};

var emptyC=true;
var changeP=false;
var img1;
var timerID=null;
var curP=11;

function clearB()
{if (document.all) {document.images[img1].border=0};
emptyC=true;
curP=11;
changeP=false;
return}

function moveP(wP)
{clearTimeout(timerID);
if (emptyC)
{img1=wP;
if (document.all) {document.images[img1].border=1};
emptyC=false;
timerID=setTimeout('clearB()',5000)}
else
{if (img1 != wP)
{if ((document.images[img1].src != Piece[0].src) && !changeP)
{document.images[wP].src=document.images[img1].src;
document.images[img1].src=Tph+'_.gif'}
clearB()}
else
{curP--;
if (curP<0) {curP=Piece.length-1};
document.images[img1].src=Piece[curP].src;
changeP=true;
timerID=setTimeout('clearB()',3000)}}
}

function up1(e)
{if (document.all)
{if (event.button==1) {moveP(event.srcElement.name)}}
else
{if (e.which==1) {moveP(e.target.name)}}
}

function ViewTable(N,S,L)
{with (document)
{writeln('<TABLE BORDER="1" CELLSPACING="0" CELLPADDING="0" ALIGN="left">');
writeln('<TR><TD><table border="0" CELLSPACING="0" CELLPADDING="0">');
for (i=8;i>=1;i--)
{writeln('<tr>');
for (j=1;j<=8;j++)
{if ((i+j)%2==0) {writeln('<td width="27" height="27" align="center" valign="middle" bgcolor="#C5AB7A"><img name="p'+i+''+j+'" src="'+Tph+'_.gif"></td>')}
else {writeln('<td width="27" height="27" align="center" valign="middle" bgcolor="#E0DFA9"><img name="p'+i+''+j+'" src="'+Tph+'_.gif"></td>')}
images['p'+i+''+j].onmouseup=up1}
writeln('</tr>')
}
writeln('</table></TD></TR></TABLE>');
writeln('<table border="0" CELLSPACING="0" CELLPADDING="0">');
writeln('<tr><td>&nbsp;&nbsp;&nbsp;</td>');
writeln('<td><FORM NAME="Dinfo">');
writeln('<TEXTAREA NAME="Solve" ROWS="9" COLS="42" WRAP="PHYSICAL" ReadOnly>Loading pieces ..</TEXTAREA><BR><BR>');
if (N==1)
{writeln('<INPUT TYPE="Button" VALUE="|<" onClick="NewDiagram(1)">');
writeln('<INPUT TYPE="Button" VALUE="< " onClick="PrevDiagram()">');
writeln('<INPUT TYPE="Button" VALUE=" >" onClick="NextDiagram()">');
writeln('<INPUT TYPE="Button" VALUE=">|" onClick="NewDiagram(Dg.length-1)">')
}
writeln('<INPUT TYPE="TEXT" NAME="Go" Size="3">');
if (N==1)
{writeln('<INPUT TYPE="Button" VALUE="Go" onClick="GoDiagram()">')
}
if (S==1)
{writeln('<INPUT TYPE="Button" VALUE="Solution" onClick="ViewSolution()">')
}
if (L==1)
{writeln('<INPUT TYPE="Button" VALUE="List" onClick="ViewList()">')
}
writeln('<INPUT TYPE="Button" VALUE=" ? " onClick="Helpme()">');
writeln('</td></tr></form></table>');
}}

var Fl;
function NewDiagram(Number)
{if (!emptyC) {clearB()}; 
var Bc=0;
var Wc=0;
var Nc=0;
var Nb;
Nd=Number;
Fl='\n';
for (i=8;i>=1;i--)
{for (j=1;j<=8;j++)
{Nb=Dg[Number][8-i][j-1];
if (Nb<17) {document.images['p'+i+''+j].src=Piece[Nb].src}
else {Fairy(Nb,i,j)}
if ((Nb>0) && (Nb%100<20))
{if (Nb%100==19){Nc++}
else {if ((Nb+2)%2==0){Bc++}else{Wc++}} 
}}}
with (document.Dinfo)
{if (Nc>0) {Solve.value=Dg[Number][8]+' \n'+Dg[Number][9]+'\n'+Dg[Number][11]+'\n('+Wc+' + '+Bc+' + '+Nc+')'+Fl}
else {Solve.value=Dg[Number][8]+' \n'+Dg[Number][9]+'\n'+Dg[Number][11]+'\n('+Wc+' + '+Bc+')'+Fl}
Go.value=Nd}
return}

var FPiece=new Array();
function LoadFp()
{for (i=0;i<FPiece.length;i++)
{Piece[i+17]=new Image();
Piece[i+17].src=Tph+FPiece[i][1]}}

function Fairy(Np,Ay,Ax)
{for (k=0;k<FPiece.length;k++)
{if (Np==FPiece[k][0])
{document.images['p'+Ay+''+Ax].src=Piece[k+17].src;
if (FPiece[k][2]!='') {Fl+=FPiece[k][2]+Square(Ax)+Ay+', '}
break}}
return}

function Square(X)
{if (X==8) {return 'h'}
if (X==7) {return 'g'}
if (X==6) {return 'f'}
if (X==5) {return 'e'}
if (X==4) {return 'd'}
if (X==3) {return 'c'}
if (X==2) {return 'b'}
if (X==1) {return 'a'}}

var Cp='';   // list code page
function ViewList()
{with (parent.frames['AllText'].document) 
{open();
writeln('<HTML><HEAD>');
if (Cp!='') {writeln('<META HTTP-EQUIV="Content-type" CONTENT="text/html; charset='+Cp+'">')};
writeln('<SCRIPT LANGUAGE="JavaScript">');
writeln('function GoD(GV)');
writeln('{parent.frames["Diagram"].NewDiagram(GV)}');
writeln('</SCRIPT>');
writeln('</HEAD>');
writeln('<BODY bgcolor="#FAF5DC" text="#000000" link="#A52A2A" vlink="#A52A2A" alink="#A52A2A">');
for (i=1;i<Dg.length;i++)
{if (Dg[i][11][0].indexOf('\n',0)>=0)
{writeln('<A href="javascript:GoD('+i+')">N.'+i+'</A> '+Dg[i][8][0].bold()+', '+Dg[i][9]+', '+Dg[i][11][0].substring(0,Dg[i][11][0].indexOf('\n',0))+'<BR>')}
else
{writeln('<A href="javascript:GoD('+i+')">N.'+i+'</A> '+Dg[i][8][0].bold()+', '+Dg[i][9]+', '+Dg[i][11]+'<BR>')}
}
write('</BODY></HTML>');
close()
}}

function Helpme()
{with (parent.frames['AllText'].document) 
{open();
writeln('<HTML><HEAD></HEAD>');
writeln('<BODY bgcolor="#FAF5DC" text="#000000">');
writeln('<B>CCV - Chess Composition Viewer</B><I> created by Marek Kwiatkowski</I> - dynamic presentation of chess compositions.');
writeln('<UL><li>to move piece <BR>Click the left mouse button on a piece, and then click on the destination square.');
writeln('<li>to change kind of piece (e.g. promotion) <BR>Double click the left mouse button on a piece, and then repeat clicks until the needed piece appears.');
writeln('<li>to add piece <BR>Double click the left mouse button on a clear square, and then repeat clicks until the needed piece appears.');
writeln('<li>to clear square <BR>Double click the left mouse button on a piece, and then repeat clicks until the clear square appears.');
writeln('<li>to reset position (cancel manual changes) <BR>Click the button "Go".');
writeln('<li>to navigate between diagrams <BR>Click buttons |&lt;,&lt;,&gt;,&gt;| or type the number of needed item, and then click the button "Go".');
writeln('<li>to show solution <BR>Click the button "Solution".');
writeln('<li>to show list of collection <BR>Click the button "List".</UL>');
write('</BODY></HTML>');
close()
}}

function NextDiagram()
{if (Nd+1<Dg.length) { Nd++;
NewDiagram(Nd)}
else {alert('Last!')}
}

function PrevDiagram()
{if (Nd-1>=1) {Nd--;
NewDiagram(Nd)}
else {alert('First!')}
}

function ViewSolution()
{document.Dinfo.Solve.value='Solution:\n'+Dg[Nd][10]
}

function GoDiagram()
{if (isNaN(document.Dinfo.Go.value))
{alert('Not a number!')}
else
{var GN;
GN=eval(document.Dinfo.Go.value);
if ((GN>0) && (GN<Dg.length)) {NewDiagram(GN)}
else {alert('False number!')}}
}
unit epub;

interface
{$ifdef gui4} {$define gui3} {$define gamecore}{$endif}
{$ifdef gui3} {$define gui2} {$define net} {$define ipsec} {$endif}
{$ifdef gui2} {$define gui}  {$define jpeg} {$endif}
{$ifdef gui} {$define snd} {$endif}
{$ifdef con3} {$define con2} {$define net} {$define ipsec} {$endif}
{$ifdef con2} {$define con} {$define jpeg} {$endif}//09oct2026
{$ifdef fpc} {$mode delphi}{$define laz} {$define d3laz} {$undef d3} {$else} {$define d3} {$define d3laz} {$undef laz} {$endif}
uses gossroot, {$ifdef gui}gossgui, gosstext,{$endif} {$ifdef snd}gosssnd,{$endif} gosswin, gosswin2, gossio, gossimg, gossnet, gossfast, gossteps;
{$B-} {generate short-circuit boolean evaluation code -> stop evaluating logic as soon as value is known}
//## ==========================================================================================================================================================================================================================
//##
//## MIT License
//##
//## Copyright 2026 Blaiz Enterprises ( http://www.blaizenterprises.com )
//##
//## Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
//## files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,
//## modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software
//## is furnished to do so, subject to the following conditions:
//##
//## The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//##
//## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//## OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//## LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//## CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//##
//## ==========================================================================================================================================================================================================================
//## Library.................. EPUB v2 e-book generator (epub.pas)
//## Version.................. 1.00.2050 (+0)
//## Items.................... 1
//## Last Updated ............ 25oct2026, 23oct2026, 22oct2026, 20oct2026, 19oct2026, 18oct2026, 17oct2026, 16oct2026, 15oct2026
//## Lines of Code............ 5,700+
//##
//## main.pas ................ App specific code
//## gossdat.pas ............. App specific icons and help documents
//## gossfast.pas ............ FastDraw - rapid render graphic procs
//## gossgame.pas ............ GameCore - 2D game engine with integrated menu handler, xbox controller + mouse + keyboard support and window integration
//## gamefiles.pas ........... Built-in file(s) for GameCore (optional)
//## gossgui.pas ............. GUI management and controls
//## gossimg.pas ............. Multi-format graphic procs for 8, 24 and 32 bit images with IO support
//## gossio.pas .............. File IO and low level file/folder/disk/data format procs
//## gossjpg.pas ............. JPEG IO (read/write jpeg image data via third party libraries)
//## gossnet.pas ............. Networking - ip filtering, socket management etc
//## gossroot.pas ............ App startup and control (GUI, console and service)
//## gosssnd.pas ............. Sound, audio, midi and midi based chimes
//## gossteps.pas ............ System, Folder and App images
//## gosstext.pas ............ TextCore - non-GUI and GUI text engine for text boxes
//## gosswin.pas ............. Win32 api calls for 32 and 64 bit (static / api references disabled by default)
//## gosswin2.pas ............ Win32 api calls for 32 and 64 bit (dynamic - load as required with fallback failure handling and default value(s) support)
//## gosszip.pas ............. ZIP IO (read/write zip data via third party libraries)
//##
//## ==========================================================================================================================================================================================================================
//## | Name                   | Hierarchy         | Version   | Date        | Update history / brief description of function
//## |------------------------|-------------------|-----------|-------------|--------------------------------------------------------
//## | epub__*                | family of procs   | 1.00.2000 | 18oct2026   | EPub generator - 17oct2026, 16oct2026, 15oct2026
//## ==========================================================================================================================================================================================================================
//## Performance Note:
//##
//## The runtime compiler options "Range Checking" and "Overflow Checking", when enabled under Delphi 3
//## (Project > Options > Complier > Runtime Errors) slow down graphics calculations by about 50%,
//## causing ~2x more CPU to be consumed.  For optimal performance, these options should be disabled
//## when compiling.
//## ==========================================================================================================================================================================================================================

const
   pub_filelimit                =8000;
   pub_utf8                     ='utf-8';
   pub_buildOK                  ='Built';
   pub_buildFailed              ='Build Error: ';
   pub_returnCode               =#13#10;
   pub_pageStyleCode            ='<style type="text/css">@page {margin-top:0.3em;margin-bottom:0.3em;}</style>';
   pub_buildSummary             ='-- Build Summary --';
   pub_docFiles                 ='-- Document Files --';
   pub_docMask                  ='*.txt;*.bwd;*.bwp;*.rtf';
   pub_docEMask                 ='.__recent.txt;';
   pub_OEBPS                    ='OEBPS/';
   pub_preprocessingScanLen     =1000;

   pub_fileMarker               ='file:';
   pub_fileMarkerOK             ='file(OK):';
   pub_fileMarkerNotFound       ='file(Not Found):';

   pub_noFormatMarker           ='*';
   pub_chapterOneMarker         ='>';

   pub_buildNumber_min          =0;
   pub_buildNumber_max          =9999;
   pub_buildNumber_def          =0;

   pub_headerSize_min           =10;
   pub_headerSize_max           =1200;
   pub_headerSize_def           =350;

   pub_headerAlign_min          =0;
   pub_headerAlign_max          =2;//0=left, 1=center, 2=right
   pub_headerAlign_def          =1;

   pub_headerVPad_min           =0;
   pub_headerVPad_max           =80;//0-80%
   pub_headerVPad_def           =35;

   pub_textSize_min             =10;
   pub_textSize_max             =1200;
   pub_textSize_def             =100;

   pub_textJustify_min          =0;
   pub_textJustify_max          =1;
   pub_textJustify_def          =1;

   pub_textVPad_min             =0;
   pub_textVPad_max             =80;//0-80%
   pub_textVPad_def             =5;

   pub_lineHeight_min           =80;
   pub_lineHeight_max           =500;
   pub_lineHeight_def           =150;

   pub_dropcaps_min             =0;
   pub_dropcaps_max             =7;
   pub_dropcaps_def             =2;

   pub_indentChars_min          =-20;
   pub_indentChars_max          =20;
   pub_indentChars_def          =4;

   pub_blankLine_min            =0;
   pub_blankLine_max            =2;
   pub_blankLine_def            =0;

   pub_sceneSep_min             =0;
   pub_sceneSep_max             =3;//(0)=off,  (1) "hash" -> basic sep,  (2) "hash" or "* * *" or "***" -> basic sep,  (3) "hash" or "* * *" or "***" -> enhanced sep - 24oct2026
   pub_sceneSep_def             =3;

   pub_quotesSingle_min         =0;
   pub_quotesSingle_max         =2;
   pub_quotesSingle_def         =2;

   pub_quotesDouble_min         =0;
   pub_quotesDouble_max         =2;
   pub_quotesDouble_def         =2;

   pub_formatUp_min              =0;
   pub_formatUp_max              =1;
   pub_formatUp_def              =1;

   pub_imageConversion_min      =0;
   pub_imageConversion_max      =4;
   pub_imageConversion_def      =1;

   pub_coverRatio               =1.5;//sourced from https://mcwriting.com/2022/05/26/what-size-should-an-ebook-cover-be/ - 21oct2026
   pub_coverWidth_def           =1400;
   pub_coverHeight_def          =round(pub_coverWidth_def * pub_coverRatio);

   pub_maxWidth                 =pub_coverWidth_def;
   pub_maxHeight                =pub_coverHeight_def;

   //file format types
   pub_fNone                    =0;
   pub_fText                    =1;
   pub_fImage                   =2;

   //image storage types
   pub_isImageData              =0;
   pub_isImageCover             =1;
   pub_isImageAsDoc             =2;

   //doc type
   pub_none                     =0;
   pub_html                     =1;
   pub_xhtml                    =2;
   pub_image                    =3;
   pub_titlePage                =4;
   pub_coverjpg                 =5;
   pub_contentshtml             =6;
   pub_styleSheetcss            =7;
   pub_contentopf               =8;
   pub_tocncx                   =9;

   //char commands
   pub_blankLine                =-1;
   pub_startLineHeader          =-2;

   pub_startLineIndentL         =-3;
   pub_startLineIndentC         =-4;
   pub_startLineIndentR         =-5;
   pub_startLineL               =-6;
   pub_startLineC               =-7;
   pub_startLineR               =-8;

   pub_stopline                 =-9;
   pub_sceneSep                 =-10;
   pub_skip                     =-11;

   pub_startDropCapOne          =-12;
   pub_startDropCaps            =-13;
   pub_stopDropCaps             =-14;

   pub_unusedChar               =31;
   pub_sceneSep0                =30;


type
   tpubinfo                     =record

    style                       :array[0..pred(pub_filelimit)] of byte;//0=text ,1=image
    nref                        :array[0..pred(pub_filelimit)] of longint32;
    nval                        :array[0..pred(pub_filelimit)] of longint32;
    name                        :array[0..pred(pub_filelimit)] of string;
    next                        :array[0..pred(pub_filelimit)] of string;//uppercase file extension
    data                        :array[0..pred(pub_filelimit)] of string;
    dataLen                     :array[0..pred(pub_filelimit)] of longint32;
    refdata                     :array[0..pred(pub_filelimit)] of string;
    refdataLen                  :array[0..pred(pub_filelimit)] of longint32;
    w                           :array[0..pred(pub_filelimit)] of longint32;
    h                           :array[0..pred(pub_filelimit)] of longint32;
    format                      :array[0..pred(pub_filelimit)] of string;
    headingRaw                  :array[0..pred(pub_filelimit)] of string;//for contents link
    count                       :longint32;
    count_text                  :longint32;
    count_image                 :longint32;
    firstImage                  :boolean;//assume first image to be cover image
    buildFolder                 :string;

    //book info
    title                       :string;
    fname                       :string;
    lname                       :string;
    year                        :longint32;
    month                       :longint32;
    day                         :longint32;
    rights                      :string;
    subject                     :string;
    des                         :string;
    publisher                   :string;
    isbn                        :string;
    uuid                        :string;
    firstChapterIndex           :longint32;//optional

    //system file reference
    slot_contentsHtml           :longint32;
    slot_contentsOpf            :longint32;
    slot_titlepageXhtml         :longint32;
    slot_tocNcx                 :longint32;
    slot_stylesheetcss          :longint32;

    //build options
    headerSize                  :longint32;//10-1200%
    headerAlign                 :longint32;
    headerVPad                  :longint32;
    textsize                    :longint32;//10-1200%
    textJustify                 :longint32;
    textVPad                    :longint32;
    lineHeight                  :longint32;//100-500%

    indentchars                 :longint32;
    indentFirst                 :longint32;
    dropcaps                    :longint32;
    blankLine                   :longint32;
    sceneSep                    :longint32;
    formatUp                    :longint32;
    quotesSingle                :longint32;
    quotesDouble                :longint32;

    imageConversion             :longint32;
    coverWidth                  :longint32;
    coverHeight                 :longint32;
    buildNumber                 :longint64;

    //strings
    firstError                  :string;
    docHeading                  :string;
    headersizeStr               :string;
    textsizeStr                 :string;
    lineheightStr               :string;
    coverQuality                :string;
    imageQuality                :string;

    blankLineStr                :string;
    startLineNormalHeaderStr    :string;//source 1
    startLineChapterHeaderStr   :string;//source 2
    startLineHeaderStr          :string;//uses source 1 or 2
    startLineIndentLStr         :string;
    startLineIndentCStr         :string;
    startLineIndentRStr         :string;
    startLineLStr               :string;
    startLineCStr               :string;
    startLineRStr               :string;
    startBeginContentsLineStr   :string;
    stopLineStr                 :string;
    sceneSepStr                 :string;

    //preprocessing streams
    s                           :tstr8;
    t                           :ttextcore;
    tlen                        :longint32;
    docText                     :tstr8;

    //per document formatting options
    dformatDocument             :boolean;
    dindentChars                :longint32;
    dindentFirst                :longint32;
    ddropCaps                   :longint32;
    ddropWordLimit              :longint32;
    dblankLine                  :longint32;

    end;


//Windows 1252 character set procs -> english text + latin 1 -------------------

function  windows1252__charIsLetter(const v:longint32):boolean;
function  windows1252__xmlFilterLine(const s:string):string;//limited, for xml values etc
function  windows1252__charVisible(const v:longint32):boolean;//windows-1252 -> sourced from "https://www.ascii-code.com/"


//pub procs --------------------------------------------------------------------

function  pub__build(const xbuildFile:string;var xoutputFilename,e:string):boolean;
function  pub__build2(const xbuildFile:string;const xbuildPub:boolean;var xoutputFilename,dbuildStatus:string):boolean;
function  pub__copy(const s:tbasicbwp;sbuildFolder:string):boolean;
function  pub__paste(const s:tbasicbwp;sbuildFolder:string):boolean;

//.support procs
procedure pub__init(var x:tpubinfo;const xbuildFolder:string);
procedure pub__free(var x:tpubinfo);
procedure pub__FilterBuildFile(const xbuildFile:string);
function  pub__documentFileList(const xbuildFolder,xbuildFileData:string;const xfindWordCount:boolean;var dwordcount:longint32):string;
function  pub__isDocumentFile(const x:string):boolean;
function  pub__extractDocumentFile(const x:string;var xformatDocument,xchapterOne:boolean):string;
function  pub__extractDocumentFile2(const x:string;var xhasFileMarker,xformatDocument,xchapterOne:boolean):string;
function  crc32__nonzero(const x:string):longint32;//15oct2026
function  pub__addfile(var xcore:tpubinfo;const dstyle:longint32;const xdata,xrefData:string;var dindex:longint32):boolean;

function  pub__addImage(var xcore:tpubinfo;const simageStream:tstr8;const dimageStorageStyle:longint32;var dindex:longint32):boolean;
function  pub__addImage2(var xcore:tpubinfo;const simageFileNameForRefOnly:string;const simageStream:tstr8;const dimageStorageStyle:longint32;var dindex:longint32):boolean;

function  pub__preprocess(var xcore:tpubinfo;const xfilename:string;const dformatDocument:boolean):boolean;
function  pub__addDocument(var xcore:tpubinfo;const xfilename:string;const dformatDocument,dchapterOne:boolean):boolean;
function  pub__addCoverOrImage(var xcore:tpubinfo;const xfilename:string;const xAsCover,dchapterOne:boolean):boolean;

function  pub__addContents(var xcore:tpubinfo):boolean;
function  pub__addStylesheet(var xcore:tpubinfo):boolean;
function  pub__addContentopf(var xcore:tpubinfo):boolean;
function  pub__generator:string;
function  pub__uuid(const xcore:tpubinfo):string;//20oct2026
function  pub__title(const xcore:tpubinfo):string;
function  pub__asTitle(const xlabel,xdef:string):string;//20oct2026
function  pub__author(const xcore:tpubinfo):string;
function  pub__authorR(const xcore:tpubinfo):string;
function  pub__releaseDate(const xcore:tpubinfo):string;
function  pub__addTOCncx(var xcore:tpubinfo):boolean;
function  pub__containerxml:string;
function  pub__mimetype:string;
function  pub__asEbookFilename(const n:string):string;
function  pub__buildOptionValue(const xvalue:string;const xmin,xmax,xdef:longint32):longint32;//17oct2026
function  pub__buildOptionBool(const xvalue:string;const xdef:boolean):boolean;//17oct2026
function  pub__imageIsJpeg(const sformat:string):boolean;
function  pub__imageFormatSupported(const sformat:string):boolean;
function  pub__imageMustConvert(const sformat:string;const ximageConversion:longint32):boolean;
function  pub__convertImage(const xcore:tpubinfo;const s,d:tstr8;const ximageIsCover:boolean;var e:string):boolean;
function  pub__digPad(const x:longint32):string;
procedure pub__makeStrs(var xcore:tpubinfo;const xformatDocument:boolean);
function  pub__single(const x:double):string;
function  pub__setFirstError(var xcore:tpubinfo;const xnewErrorMsg:string):boolean;
function  pub__helpText:string;
function  pub__safeBuildNumber(const x:longint64):longint64;
procedure pub__coverImageDefault(s:tstr8);
function  pub__fileFormatSupported(const xfilename:string):boolean;
function  pub__fileFormatSupported2(const xfilename:string;var xdocStyle:longint32):boolean;
procedure pub__setChapterOneOnce(var xcore:tpubinfo;const dindex:longint32);
function  pub__enforceImageLimits(const xcore:tpubinfo;const ximagedata:tstr8;var xoutW,xoutH:longint32):boolean;
function  pub__stripProtocols(const x:string):string;
function  pub__publisher(const x:string):string;
procedure pub__formatUp(const x:tstr8);
procedure pub__formatSceneSep(const x:tstr8;const xstyle:longint32);//24oct2026
procedure pub__quotesSinglePlain(const x:tstr8);
procedure pub__quotesDoublePlain(const x:tstr8);
procedure pub__quotesDoubleCurly(const x:tstr8);
procedure pub__quotesSingleCurly(const x:tstr8);
function  pub__version:string;


implementation


//Windows 1252 character set procs -> english text + latin 1 -------------------


function pub__junkLine:string;//???????????????????????????????????????
var
   p:longint32;
begin

result:='';

for p:=0 to 255 do result:=result+char(p);

end;

function windows1252__xmlFilterLine(const s:string):string;//limited, for xml values etc
var//Low-level XML/HTML conversion proc -> ADE confirmed - 23oct2026
   p                            :longint32;
   v                            :longint32;

   procedure r(const v:string);
   begin

   result                       :=result + v;

   end;

   procedure ra;
   begin

   result                       :=result + char(v);

   end;

begin

//defaults
result                          :='';

//get
for p:=1 to low__len32(s) do
begin

v                               :=byte(s[p-1+stroffset]);

case v of

9,10,32,160                     :r(#32);
34                              :r('&quot;');//required for xml
38                              :r('&amp;');//required for xml
39                              :r('&apos;');//required for xml
60                              :r('&lt;');//required for xml
62                              :r('&gt;');//required for xml
else if (v>=32) then             ra;//via utf-8

end;//case

end;//p

end;

function windows1252__charIsLetter(const v:longint32):boolean;
begin

case v of

48..57                          :result:=true;
65..90                          :result:=true;
97..122                         :result:=true;
131                             :result:=true;
138                             :result:=true;
140                             :result:=true;
142                             :result:=true;
154                             :result:=true;
158..159                        :result:=true;
161                             :result:=true;
192..214                        :result:=true;
216..246                        :result:=true;
248..255                        :result:=true;

else                             result:=false;

end;//case

end;

function windows1252__charVisible(const v:longint32):boolean;//windows-1252 -> sourced from "https://www.ascii-code.com/"
begin

case v of

33..126                         :result:=true;
128                             :result:=true;
130..140                        :result:=true;
142                             :result:=true;
145..156                        :result:=true;
158..159                        :result:=true;
160..255                        :result:=true;
else                             result:=false;

end;//case

end;


//pub procs --------------------------------------------------------------------

const
pub_coverImageDefault
:array[0..33334] of byte=(
255,216,255,224,0,16,74,70,73,70,0,1,1,0,0,1,0,1,0,0,255,219,0,67,0,32,22,24,28,24,20,32,28,26,28,36,34,32,38,48,80,52,48,44,44,48,98,70,74,58,80,116,102,122,120,114,102,112,110,128,144,184,156,128,136,174,138,110,112,160,218,162,174,190,196,206,208,206,124,154,226,242,224,200,240,184,202,206,198,255,219,0,67,1,34,36,36,48,42,48,94,52,52,94,198,132,112,132,198,198,198,198,198,198,198,198,198,198,198,198,198,198,198,198,198,198,198,198,198,198,198,198,198,198,198,198,198,198,198,198,198,198,198,198,198,198,198,198,198,198,198,198,198,198,198,198,198,198,255,192,0,17,8,3,72,2,88,3,1,34,0,2,17,1,3,17,1,255,196,0,31,0,0,1,5,1,1,1,1,1,1,0,0,0,0,0,0,0,0,1,2,3,4,5,6,7,8,9,10,11,255,196,0,181,16,0,2,1,3,3,2,4,3,5,5,4,4,0,0,1,125,1,2,3,0,4,17,5,18,33,49,65,6,19,81,97,7,34,113,20,50,129,145,161,8,35,66,177,193,21,82,209,240,36,51,98,114,130,9,10,22,23,24,25,26,37,38,39,40,41,42,52,53,54,55,56,57,58,67,68,69,70,71,72,73,74,83,84,85,86,87,88,89,90,99,100,101,102,103,104,105,106,115,116,117,
118,119,120,121,122,131,132,133,134,135,136,137,138,146,147,148,149,150,151,152,153,154,162,163,164,165,166,167,168,169,170,178,179,180,181,182,183,184,185,186,194,195,196,197,198,199,200,201,202,210,211,212,213,214,215,216,217,218,225,226,227,228,229,230,231,232,233,234,241,242,243,244,245,246,247,248,249,250,255,196,0,31,1,0,3,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,1,2,3,4,5,6,7,8,9,10,11,255,196,0,181,17,0,2,1,2,4,4,3,4,7,5,4,4,0,1,2,119,0,1,2,3,17,4,5,33,49,6,18,65,81,7,97,113,19,34,50,129,8,20,66,145,161,177,193,9,35,51,82,240,21,98,114,209,10,22,36,52,225,37,241,23,24,25,26,38,39,40,41,42,53,54,55,56,57,58,67,68,69,70,71,72,73,74,83,84,85,86,87,88,89,90,99,100,101,102,103,104,105,106,115,116,117,118,119,120,121,122,130,131,132,133,134,135,136,137,138,146,147,148,149,150,151,152,153,154,162,163,164,165,166,167,168,169,170,178,179,180,181,182,183,184,185,186,194,195,196,197,198,199,200,201,202,210,211,212,213,214,215,216,217,218,226,227,228,229,230,231,232,233,234,242,243,244,245,
246,247,248,249,250,255,218,0,12,3,1,0,2,17,3,17,0,63,0,106,146,8,62,149,161,109,120,48,21,133,103,10,80,9,60,12,214,205,26,180,107,201,26,78,188,26,162,201,229,190,13,58,218,99,19,225,233,247,44,165,178,166,146,18,35,95,90,155,200,98,185,21,92,55,53,167,110,119,70,40,110,192,221,138,59,74,158,69,39,152,17,186,85,249,97,12,43,58,84,96,196,83,78,224,157,203,113,78,173,222,166,89,0,25,36,86,80,37,79,20,255,0,53,152,96,210,113,41,162,203,74,175,48,2,175,40,194,138,201,139,112,148,28,86,152,122,153,34,26,42,234,81,134,143,119,165,101,71,30,246,207,97,91,23,138,94,2,23,173,102,194,49,149,61,106,163,176,209,67,81,71,64,49,247,107,52,244,174,173,172,214,104,74,156,228,215,53,117,1,130,118,140,246,53,18,38,68,246,110,190,94,214,56,57,171,152,200,235,154,203,242,100,92,28,85,171,89,92,156,48,224,85,43,141,54,90,11,197,65,44,120,201,21,99,52,215,82,84,144,42,209,72,100,0,109,162,97,206,234,75,112,236,219,64,250,212,147,198,193,14,104,24,244,59,128,197,50,246,2,168,26,146,201,183,72,20,
213,187,241,254,143,64,24,227,173,105,69,242,91,115,233,84,173,212,52,160,26,187,116,219,98,197,0,204,215,57,99,79,88,131,167,94,105,132,83,226,108,113,64,88,70,131,10,77,68,7,56,21,115,239,46,42,53,135,13,146,104,16,235,116,217,201,164,155,150,38,165,197,49,134,104,26,33,82,65,173,203,73,214,72,128,36,2,43,16,140,26,107,220,52,107,181,8,230,134,199,38,94,212,53,5,66,209,68,51,158,166,178,25,139,154,78,88,230,149,70,43,45,204,111,114,88,6,1,53,102,35,243,138,130,35,242,154,154,35,135,21,170,90,26,197,104,92,205,75,9,24,235,85,243,72,36,42,120,164,34,212,172,2,114,106,164,103,18,102,135,144,191,90,104,201,110,58,211,3,64,116,166,56,230,149,14,84,102,154,231,38,144,13,39,2,170,176,203,19,82,200,252,98,162,221,64,0,24,168,39,251,213,98,160,157,122,26,96,64,249,219,129,80,85,144,113,80,54,51,192,168,104,153,2,244,197,55,20,240,167,25,197,54,149,136,29,8,253,226,253,106,212,139,134,226,170,197,247,193,173,14,24,102,170,38,145,43,237,111,74,146,25,66,46,13,61,248,83,85,141,81,70,180,
87,241,44,124,142,71,74,112,186,19,14,58,86,64,201,56,29,106,253,180,101,19,154,1,147,210,128,113,210,149,16,181,78,16,5,197,2,43,16,49,89,179,41,14,120,239,90,206,152,239,85,103,64,84,156,80,52,103,212,246,139,186,92,250,84,21,102,199,253,97,166,83,52,0,192,167,103,11,154,122,196,204,185,2,171,205,230,71,195,14,181,36,15,71,221,197,35,21,108,174,106,40,136,25,36,212,101,240,197,133,0,87,157,54,57,20,235,79,245,227,223,138,108,207,189,178,106,107,4,223,114,190,213,93,10,53,86,34,69,17,175,207,131,86,64,249,113,76,216,17,183,19,81,113,25,119,64,9,142,42,148,196,231,2,174,92,54,249,88,251,213,11,169,2,28,14,77,59,133,236,87,156,140,138,42,62,89,185,162,161,234,100,245,54,128,192,169,34,125,135,56,205,52,16,69,40,197,89,160,231,109,205,187,165,75,229,187,38,236,113,78,180,135,123,229,135,2,180,196,99,102,48,42,92,172,75,102,70,49,90,54,109,152,233,101,128,50,240,5,85,71,48,177,7,52,94,225,185,162,79,21,11,168,39,165,57,28,48,6,148,242,106,86,130,90,20,103,128,245,81,73,4,12,27,36,
85,237,180,224,49,85,204,85,200,118,0,115,77,146,85,136,101,141,45,209,96,159,32,57,246,172,153,188,198,63,54,77,11,81,167,114,235,106,43,180,128,181,64,74,124,220,250,154,106,68,238,216,0,212,255,0,100,56,237,154,171,14,198,130,76,171,22,238,188,86,45,218,172,211,153,49,205,105,198,133,99,218,121,172,251,128,22,82,0,165,97,88,173,32,226,163,83,181,169,151,114,124,224,41,233,76,73,135,122,57,144,93,26,80,159,48,129,87,196,99,203,43,85,44,226,219,24,99,201,60,213,205,220,83,2,56,161,17,14,191,141,85,189,184,82,187,5,92,50,41,6,178,39,255,0,88,126,180,208,209,37,143,252,124,10,187,168,56,17,109,238,106,173,130,226,77,199,129,77,189,147,124,216,7,32,83,27,220,44,215,46,91,210,172,220,129,229,28,154,100,110,145,198,8,35,165,84,154,82,231,169,197,0,68,105,1,7,161,161,190,225,168,98,111,155,21,45,234,38,245,177,105,31,29,106,101,109,221,42,190,56,161,88,175,122,99,177,35,201,135,3,28,83,137,24,206,106,188,199,45,154,97,36,140,102,145,35,165,112,79,21,93,250,212,135,165,70,221,106,100,
76,133,83,205,58,153,214,158,15,0,119,165,18,81,36,56,193,169,83,151,21,26,169,81,200,169,97,25,108,214,136,217,108,89,29,41,166,157,69,4,136,137,184,212,139,24,83,72,152,6,145,155,39,138,64,89,67,197,48,212,33,206,122,213,128,132,174,104,2,180,160,175,53,13,79,113,154,130,152,199,110,226,160,153,137,53,62,211,138,99,160,84,45,222,128,43,57,192,168,123,210,177,201,230,146,161,179,38,238,203,25,249,106,34,135,52,228,36,117,7,20,227,85,185,105,93,13,85,219,83,192,227,59,115,205,70,1,34,162,102,42,224,138,30,128,244,47,75,247,42,181,88,140,153,162,200,166,24,29,122,138,105,149,113,136,118,184,53,171,10,23,64,122,85,27,120,9,124,176,173,37,220,23,2,128,38,80,20,98,161,146,66,91,142,148,51,19,77,164,32,39,112,230,163,117,220,184,245,169,40,226,129,153,178,64,234,120,25,171,90,124,46,92,228,98,165,118,10,50,105,214,147,167,155,201,166,51,81,70,20,10,169,126,87,203,198,121,169,46,103,217,30,84,245,172,233,11,184,220,73,53,40,146,51,81,200,72,20,252,211,28,100,85,12,132,213,173,62,64,
147,140,213,50,235,187,25,167,33,195,12,83,25,211,3,145,85,239,31,9,183,185,167,90,182,248,84,251,82,92,0,88,28,84,117,17,153,50,152,212,179,116,172,121,27,123,147,93,5,220,126,100,12,49,210,185,246,24,36,80,204,228,198,131,200,162,159,26,131,214,138,18,4,104,71,46,209,140,214,173,138,36,136,88,224,214,88,140,99,222,180,116,214,216,8,166,203,102,164,104,20,112,0,169,42,32,212,236,147,89,52,69,135,226,170,221,66,8,220,42,124,26,24,124,184,161,8,207,130,86,87,218,77,104,47,34,160,242,87,118,113,83,41,197,83,45,143,198,41,167,173,59,57,160,138,146,10,211,200,20,227,60,212,107,181,151,52,251,148,82,164,247,170,27,217,114,1,173,22,198,136,188,54,143,74,130,105,162,67,141,194,170,179,49,29,77,85,117,108,158,9,167,97,151,228,185,69,94,13,103,200,229,220,177,239,77,230,154,91,7,25,166,5,75,165,196,157,58,212,31,74,181,119,130,1,6,170,86,82,220,201,238,94,181,190,104,240,172,120,30,213,172,146,137,35,12,58,26,231,85,75,28,10,219,128,226,32,51,218,170,37,68,148,138,137,162,82,219,141,44,
146,109,94,189,106,147,74,196,242,106,203,47,28,42,26,206,115,151,38,173,239,204,4,213,35,201,166,52,46,236,210,19,129,205,77,28,37,151,36,84,18,140,10,1,141,103,249,8,205,67,23,223,169,54,110,90,69,77,167,38,179,107,83,61,91,2,199,204,198,106,90,133,184,146,165,166,138,136,143,201,166,211,197,48,213,3,16,211,88,12,83,207,67,81,128,89,128,28,154,150,67,16,10,209,178,183,1,55,50,252,222,244,182,214,97,64,103,28,253,106,224,24,24,164,144,36,49,162,83,212,84,101,85,56,81,82,200,219,84,146,106,184,109,220,230,172,177,105,71,74,76,243,78,29,40,0,0,158,148,20,97,218,164,135,173,72,221,41,1,87,21,101,92,132,198,105,165,70,115,76,118,219,64,4,131,112,53,16,24,169,137,227,53,1,52,0,142,196,14,42,6,98,65,205,76,106,18,57,52,198,84,61,105,240,227,204,5,186,81,34,224,211,51,80,100,244,102,153,69,101,224,10,168,195,12,69,79,106,251,162,193,60,212,50,2,28,230,169,26,38,47,240,213,119,233,83,55,221,168,142,59,208,213,194,69,203,91,152,227,132,41,60,143,106,113,190,83,235,249,86,125,29,232,70,
119,55,96,195,128,125,106,214,6,42,165,155,109,133,115,215,21,44,243,109,24,7,154,102,136,15,90,74,175,231,154,4,133,169,12,177,65,168,144,156,212,132,208,5,107,166,35,2,160,67,134,205,89,184,25,92,213,66,13,49,150,140,187,128,5,169,210,76,190,72,93,220,214,91,100,30,180,153,57,164,34,224,110,121,167,179,225,73,168,20,229,70,104,145,182,161,166,12,166,205,150,38,172,217,6,46,79,97,82,90,219,36,208,146,71,57,245,169,228,140,91,199,133,24,169,70,105,106,74,47,26,17,133,106,67,168,72,236,51,207,208,86,121,57,60,213,219,52,30,89,56,239,85,99,75,11,45,241,32,168,224,125,43,46,79,188,107,66,242,32,188,129,84,100,92,208,76,144,197,5,142,20,115,69,79,102,191,190,4,209,72,139,26,16,47,152,248,237,90,72,161,70,5,82,176,28,30,42,102,184,195,224,14,134,153,173,139,97,200,167,9,152,84,42,114,1,165,165,97,22,146,126,57,167,249,128,247,21,86,49,147,82,152,249,168,104,155,18,156,83,77,32,233,75,154,6,57,13,36,236,71,74,64,112,105,196,6,28,210,19,220,168,88,158,180,205,138,192,226,159,118,155,
35,36,84,54,195,228,60,214,137,148,134,136,62,110,115,138,155,203,93,184,199,20,74,226,53,201,168,86,228,147,200,166,50,79,179,199,130,54,138,161,119,101,243,101,50,51,87,126,211,207,2,148,182,254,113,64,25,230,193,26,28,28,238,197,99,200,133,28,169,237,93,69,98,106,144,236,151,120,239,81,36,68,145,4,108,138,157,179,82,172,167,31,41,170,84,170,196,28,138,74,66,82,177,166,33,145,198,72,52,214,183,117,25,197,59,79,184,146,87,42,220,138,208,101,220,132,86,137,154,41,24,242,74,219,118,103,138,141,88,138,146,226,35,27,156,210,64,155,220,103,160,160,87,52,84,170,195,150,233,138,205,184,144,60,159,47,74,183,114,223,38,193,89,237,214,129,49,87,165,58,154,157,13,58,129,161,8,4,102,149,114,78,42,120,20,17,200,169,130,40,237,72,10,178,199,177,65,168,91,165,104,58,7,24,170,18,13,172,71,165,2,98,3,197,93,179,183,0,111,35,158,213,86,8,204,146,15,65,90,200,48,0,160,73,10,40,52,19,129,72,175,186,130,138,247,141,242,129,81,199,254,171,138,158,226,47,48,103,52,213,77,169,138,99,42,141,204,221,
234,218,140,45,50,56,246,147,82,30,148,8,88,201,221,83,26,100,32,119,169,49,154,64,54,161,158,172,17,80,78,56,20,1,9,99,138,109,20,102,152,197,168,100,227,165,75,154,133,185,52,1,17,198,14,106,19,83,17,81,178,243,82,200,146,22,22,101,113,131,222,174,78,185,0,212,112,66,170,67,30,181,98,68,220,180,33,197,20,228,61,5,71,78,102,204,152,161,134,5,59,131,119,17,86,151,143,49,104,90,107,245,20,9,173,13,79,57,17,58,140,129,235,81,163,249,185,53,64,19,142,181,122,5,218,130,129,166,63,109,74,145,129,205,55,165,30,105,6,153,68,216,20,184,53,15,154,125,41,233,47,56,52,0,178,12,173,83,147,33,186,86,150,1,21,94,120,65,228,80,6,83,231,117,79,4,67,25,97,78,104,50,221,106,96,0,24,20,1,27,12,26,134,127,245,117,101,98,44,165,179,81,28,19,130,51,64,6,153,187,45,215,21,106,233,55,71,73,12,168,184,85,80,42,99,205,36,36,172,101,236,57,232,106,229,153,32,96,212,172,0,29,5,16,142,73,166,59,142,153,55,198,69,101,176,33,136,173,150,34,52,220,70,107,54,229,149,223,42,49,64,210,32,86,42,114,40,160,12,154,
41,49,61,13,56,228,49,142,59,211,226,143,204,125,205,75,28,33,148,19,83,0,35,94,41,128,224,224,113,82,70,67,156,85,82,121,205,88,130,23,200,96,120,164,197,114,215,151,142,69,58,164,11,129,138,97,235,81,114,83,18,156,6,105,42,68,35,29,40,99,98,109,160,83,186,211,27,138,146,74,247,217,49,225,106,8,23,98,1,220,212,238,225,142,42,6,111,156,98,180,72,180,65,122,199,112,21,89,95,21,161,60,34,69,12,106,171,194,49,192,170,24,251,112,173,203,85,134,76,14,42,130,130,135,25,173,40,254,100,25,244,160,68,53,94,250,31,58,221,189,69,93,120,251,211,84,6,5,77,38,7,38,70,9,30,148,118,171,58,132,62,69,195,1,208,243,85,171,22,100,205,93,41,211,203,43,208,231,53,165,92,212,82,180,109,149,56,173,251,89,188,232,67,119,197,92,89,113,33,212,23,247,57,170,112,140,38,71,90,187,168,16,32,199,173,83,132,126,238,180,40,99,49,36,230,171,191,83,87,76,96,213,57,23,107,17,67,9,2,80,239,140,1,66,119,168,152,228,212,73,146,217,106,57,25,84,85,164,96,87,53,93,84,24,129,30,148,192,204,189,13,82,41,23,115,138,165,
42,134,144,227,169,160,200,199,189,55,39,57,239,64,236,104,91,194,34,79,115,83,85,72,46,51,133,97,87,0,160,67,88,100,84,106,72,108,10,152,142,56,166,164,120,57,61,105,140,87,108,40,205,71,75,48,61,123,82,47,74,66,10,74,13,2,128,28,173,131,82,163,10,174,196,47,94,244,198,144,131,193,160,5,184,187,42,248,94,213,81,174,29,155,36,211,102,63,61,50,128,45,131,144,13,7,165,50,57,1,24,52,49,230,152,196,205,52,211,177,81,150,57,192,20,199,113,74,230,162,111,188,42,202,174,58,212,51,140,16,106,89,18,44,47,65,78,222,113,81,3,251,176,104,13,235,76,165,177,85,242,28,159,122,144,29,192,83,166,140,20,220,58,211,34,233,205,66,220,133,163,29,192,235,72,196,17,77,229,228,10,59,213,175,179,96,117,170,29,202,202,55,48,2,180,16,96,1,84,148,121,114,140,246,171,101,247,125,218,1,18,83,122,154,146,56,201,28,212,171,26,129,210,129,149,246,145,73,156,84,151,7,106,241,85,75,18,105,140,176,39,40,70,106,79,180,134,24,34,169,19,235,72,185,102,218,40,25,100,156,209,77,48,176,92,147,73,158,40,17,125,81,94,45,
190,162,168,221,67,229,28,3,154,81,43,175,67,81,200,229,142,73,160,99,34,56,145,79,189,104,118,172,153,152,198,195,6,180,99,152,50,46,7,106,87,37,177,206,50,180,182,227,45,77,144,252,181,8,185,104,248,81,64,203,23,146,13,187,5,101,188,128,54,49,86,89,203,156,158,181,82,225,54,157,195,189,15,65,55,97,204,192,70,79,225,69,87,222,74,227,181,21,155,145,14,87,58,43,121,20,166,51,86,150,49,44,100,131,210,178,21,217,122,28,86,150,155,46,224,85,143,53,163,45,145,48,218,72,62,181,165,104,225,163,2,170,93,71,181,179,142,41,45,102,40,216,237,73,234,132,245,70,173,52,167,52,170,114,1,165,172,136,216,136,173,32,200,169,72,205,52,175,53,87,42,227,76,155,70,77,55,120,145,78,13,54,113,133,168,98,87,35,131,78,193,98,55,5,88,212,125,234,89,81,134,73,168,135,90,181,177,72,153,67,184,3,181,63,236,172,121,169,97,42,177,130,106,117,32,142,42,27,37,179,60,217,146,217,61,41,173,48,141,246,227,129,90,101,107,54,254,16,167,112,166,165,112,76,145,93,93,51,77,92,118,168,96,112,80,166,104,14,209,182,15,74,
162,138,90,213,190,224,37,81,200,235,88,149,212,206,209,73,19,43,96,230,185,185,211,100,132,118,168,146,34,72,138,180,180,153,14,246,78,216,172,234,181,98,251,25,177,214,166,34,91,154,23,132,62,22,153,4,99,24,168,203,22,60,154,116,115,5,144,47,173,108,104,78,232,161,73,244,172,169,14,88,154,209,187,151,100,88,238,107,48,154,66,28,131,174,106,2,57,169,75,96,84,102,162,68,50,197,180,132,252,134,158,233,205,71,102,155,156,183,97,83,203,129,85,19,72,108,66,70,41,189,234,78,188,84,36,144,245,67,122,22,98,93,188,247,171,208,182,86,169,142,130,173,194,70,204,80,4,212,82,170,150,25,20,50,149,60,210,17,90,87,36,226,145,77,62,100,0,110,168,149,199,126,148,192,147,173,70,242,44,125,79,53,20,183,136,191,115,36,213,67,35,59,228,154,68,220,89,37,119,147,36,212,232,225,187,213,106,3,17,208,208,52,236,73,49,249,234,58,83,147,201,165,84,36,102,128,21,6,90,166,198,127,26,100,72,119,100,244,171,137,26,144,15,165,49,140,88,50,58,213,86,140,164,184,173,44,84,18,199,206,105,1,21,69,50,23,198,42,90,
74,99,181,196,69,218,128,19,76,110,181,35,28,10,136,208,52,135,3,152,200,53,4,125,72,169,123,26,128,28,53,38,68,133,249,145,242,59,85,200,46,55,157,173,214,160,0,55,81,154,34,82,38,24,233,64,172,73,116,128,124,194,167,178,140,178,238,110,148,201,192,108,3,86,81,210,40,71,74,10,177,51,50,198,57,56,170,210,92,147,144,189,42,25,167,50,30,188,82,70,187,185,52,199,97,75,51,122,154,97,226,173,196,136,6,8,161,237,149,186,26,6,81,45,154,150,212,102,81,76,120,89,79,34,157,6,86,85,166,6,137,92,140,84,79,8,3,57,169,199,74,108,128,178,144,41,8,164,106,39,56,206,59,213,147,17,206,42,188,202,84,226,129,148,228,12,79,57,171,214,202,86,49,158,181,18,46,231,0,213,239,47,0,98,166,214,100,90,204,142,70,249,106,169,60,213,243,8,101,198,106,172,240,148,228,116,170,69,33,128,224,80,234,36,143,29,234,54,125,162,136,228,245,161,131,182,197,119,67,27,96,209,83,220,242,160,226,138,197,173,76,164,172,203,117,98,205,202,206,61,42,12,84,145,240,115,91,26,155,115,167,153,23,21,155,202,182,59,138,208,178,98,
241,115,218,171,92,199,137,79,189,66,236,74,46,90,77,189,113,220,85,154,203,180,96,146,214,152,60,84,201,88,150,133,164,199,52,180,84,146,71,36,123,133,67,23,200,219,79,21,106,160,150,51,187,112,170,76,164,194,117,6,51,84,8,171,165,254,66,13,83,61,106,226,82,23,113,198,42,197,180,157,141,37,188,97,215,154,115,219,178,156,173,38,208,153,104,28,212,87,49,239,67,85,204,205,23,80,106,116,184,73,23,25,230,166,214,21,140,102,99,28,159,74,176,238,146,69,156,224,212,119,168,4,164,142,245,18,70,89,115,90,22,70,77,83,189,139,141,226,174,178,21,235,80,205,25,146,61,162,147,90,9,153,117,45,179,132,126,123,212,110,133,28,169,237,71,165,103,179,51,52,71,90,142,17,190,231,61,133,42,182,216,114,77,86,87,33,137,29,235,91,154,92,179,123,32,119,0,118,168,22,38,101,206,56,167,199,19,187,130,65,197,91,145,130,33,20,5,174,102,72,8,52,222,181,44,220,243,77,137,55,184,25,192,165,98,26,212,181,102,49,17,250,211,228,66,199,138,122,40,11,129,79,233,77,104,104,180,42,149,43,72,34,222,192,213,162,1,161,34,
52,238,55,169,25,24,226,149,88,175,74,116,137,134,165,17,113,214,128,44,91,220,1,242,182,0,169,93,195,116,172,246,27,106,72,229,11,141,199,2,144,19,202,50,134,169,109,32,55,21,120,16,195,32,228,83,100,0,70,196,211,21,244,49,138,146,212,240,160,12,80,199,230,52,162,149,132,144,195,71,90,126,51,72,163,230,160,44,60,12,46,42,72,192,197,48,245,166,185,194,113,76,189,145,103,42,59,138,154,50,54,245,172,180,203,48,25,171,139,198,5,34,86,165,193,81,204,66,161,38,158,157,5,87,189,39,0,80,4,97,131,12,138,97,124,26,34,205,69,43,101,184,166,23,177,33,109,212,148,216,1,38,158,221,104,67,76,65,80,149,32,244,169,176,69,40,228,208,193,171,145,163,142,149,98,0,12,130,170,63,18,28,85,203,111,153,197,36,201,76,91,142,26,161,220,72,197,75,116,223,188,192,237,81,10,101,160,0,158,149,102,36,42,188,210,64,0,4,212,224,80,13,145,72,251,5,17,220,144,121,233,73,112,14,58,85,106,105,2,70,150,228,148,117,166,37,184,89,55,103,53,77,28,169,205,95,134,80,203,72,86,37,29,41,9,227,138,99,74,160,17,154,141,24,
159,165,33,15,29,106,43,152,203,140,138,150,143,106,0,173,111,1,223,185,134,42,222,49,66,224,80,204,7,36,208,2,230,169,92,75,184,145,86,183,130,164,131,89,207,203,154,104,104,138,110,212,196,108,83,166,60,227,210,163,164,102,221,153,53,195,169,140,0,104,170,231,173,21,147,122,137,187,154,212,225,77,165,205,108,106,141,109,53,242,132,84,215,113,228,110,21,71,76,148,9,182,231,173,107,178,134,21,155,209,144,244,102,64,56,53,165,111,32,116,170,55,8,85,143,20,64,199,120,3,53,77,92,123,154,162,138,141,27,142,105,225,129,239,89,17,97,104,60,138,40,160,69,105,163,207,34,170,176,193,173,34,42,140,235,135,60,86,145,101,197,143,182,56,56,171,157,106,132,13,135,21,120,30,42,101,184,164,53,227,12,48,106,148,246,229,14,229,53,161,65,0,140,26,73,138,230,20,153,99,205,73,8,192,171,87,22,188,150,0,85,110,156,86,169,220,180,194,68,14,13,84,100,34,173,230,162,113,64,204,123,216,200,125,221,141,86,61,43,98,242,61,240,16,7,34,177,207,90,206,72,137,45,73,26,98,209,132,197,17,191,206,50,42,58,124,67,
46,40,76,75,115,89,113,180,31,106,167,59,6,115,138,83,35,1,142,106,46,245,165,141,108,7,161,168,70,119,113,83,80,0,28,226,134,76,149,203,80,130,35,27,169,93,176,106,8,46,50,112,115,78,119,13,66,42,36,224,247,169,21,197,86,137,187,84,135,218,128,39,192,106,66,14,106,52,125,191,120,241,80,222,93,96,40,137,190,184,164,216,175,98,119,85,3,44,113,89,247,18,135,109,171,208,84,108,239,41,193,98,105,66,226,149,238,77,238,94,211,216,236,32,154,154,232,254,228,226,160,180,66,20,177,239,82,220,243,17,170,40,206,250,211,241,80,150,37,170,122,19,184,69,220,111,74,150,56,251,211,7,90,176,184,197,50,136,221,113,81,75,247,113,87,22,50,244,175,24,92,100,10,4,246,40,91,198,75,230,174,198,185,52,1,143,74,146,32,75,113,72,75,65,226,145,212,55,81,79,101,219,77,99,129,64,16,72,160,12,10,163,42,21,53,117,142,77,53,148,50,242,40,6,138,241,56,69,62,180,232,219,124,128,98,152,232,65,165,129,182,202,9,166,45,139,237,16,43,85,93,118,181,92,7,138,175,114,59,208,82,101,70,140,177,205,17,200,81,184,167,250,
212,39,173,4,201,88,176,91,123,238,52,181,2,30,106,113,210,132,84,118,30,173,182,166,142,80,93,65,168,85,9,236,106,194,70,0,4,142,104,25,121,224,89,163,224,214,85,196,6,25,49,90,48,73,177,176,79,21,37,212,106,241,231,2,129,38,100,195,22,234,177,26,108,20,229,80,188,1,78,160,8,88,28,211,214,145,186,208,189,104,2,81,69,32,162,144,133,168,46,143,202,42,93,192,244,34,170,220,22,221,237,77,13,17,135,61,5,39,66,73,171,22,81,134,124,144,8,21,53,204,40,78,48,5,12,25,144,237,185,201,164,171,63,99,59,250,140,83,46,97,242,128,197,71,67,38,138,253,232,164,162,179,17,166,205,129,81,23,57,206,105,95,165,50,186,13,203,154,107,237,186,4,154,233,151,165,114,214,35,247,193,136,233,93,52,13,190,48,107,57,145,50,27,184,242,51,85,99,194,182,107,66,85,12,132,85,29,167,119,74,34,244,18,47,15,153,106,50,172,15,20,248,126,232,205,75,83,123,10,246,32,14,195,173,61,101,205,60,128,105,141,24,237,69,208,104,60,54,106,189,200,201,226,151,149,168,228,98,199,154,105,106,52,138,196,148,113,158,43,70,39,12,163,
6,168,76,50,153,164,181,148,171,129,85,36,54,141,65,69,68,30,164,83,154,206,196,52,35,140,174,43,46,97,177,200,173,99,89,215,203,135,205,84,88,226,86,200,166,55,38,146,151,181,104,88,215,255,0,86,223,74,193,112,67,156,245,205,111,142,181,153,169,64,99,148,54,14,15,122,137,34,100,138,70,156,156,48,166,211,208,22,53,49,33,23,4,101,151,53,17,24,56,171,80,182,70,42,57,98,203,18,43,83,107,144,82,49,192,63,74,181,20,64,46,90,171,74,87,13,235,73,137,178,56,71,83,83,198,165,207,21,12,36,5,108,154,150,221,246,191,94,13,40,236,40,189,9,210,50,173,79,199,231,78,99,242,228,84,62,97,221,84,94,229,57,183,171,144,196,212,92,214,149,194,43,71,146,58,85,51,129,214,179,104,201,161,168,48,185,167,103,138,50,13,28,98,169,13,19,197,51,2,23,60,85,137,207,238,240,123,213,56,135,57,244,169,157,139,1,85,98,210,34,88,50,219,177,197,21,102,5,224,230,163,117,1,141,9,88,105,88,138,172,47,65,81,128,9,169,71,74,6,79,1,231,20,147,103,52,216,155,6,166,96,24,122,208,73,94,173,91,237,219,199,90,128,70,75,99,21,
106,52,8,188,80,3,200,7,173,86,185,198,222,42,195,253,218,175,40,202,26,4,84,205,46,114,42,38,39,52,168,104,42,192,195,218,162,144,96,130,42,103,166,17,184,115,76,26,45,67,34,178,96,30,104,156,101,42,164,45,178,81,87,95,149,53,36,162,151,64,106,32,187,218,173,21,24,193,166,109,10,120,20,198,245,25,176,14,148,170,248,235,78,61,42,58,2,197,209,50,99,173,72,36,82,56,53,157,158,40,141,143,154,57,164,38,105,102,172,199,56,217,134,170,163,165,20,1,28,143,182,76,246,167,171,100,113,85,231,63,53,49,36,43,76,171,22,91,173,2,163,18,228,96,212,131,165,2,100,138,120,160,224,212,116,82,17,93,201,71,56,52,140,90,67,159,74,116,163,45,82,42,109,78,148,202,36,176,32,103,52,249,91,115,212,22,249,4,212,196,14,244,9,141,170,215,248,242,151,235,86,78,51,197,82,188,96,196,1,218,165,173,9,145,78,138,40,172,140,203,239,210,153,86,99,140,72,112,105,205,20,107,197,116,92,222,228,150,235,182,49,91,22,12,76,120,53,155,108,161,200,85,173,104,80,70,184,21,18,33,147,154,167,51,170,185,28,85,146,107,58,231,
253,105,169,136,145,118,7,12,56,53,61,102,90,185,87,197,105,41,200,165,36,13,14,162,129,77,38,164,145,24,10,133,212,100,212,132,211,13,90,45,34,7,28,17,84,199,202,255,0,67,86,174,91,96,226,169,242,107,66,141,72,89,93,71,76,212,185,192,170,22,200,219,179,208,85,218,205,162,69,12,125,106,27,165,223,29,74,70,41,141,210,132,22,40,197,14,126,245,15,14,58,116,171,35,173,72,19,112,230,174,229,25,202,191,48,168,245,181,255,0,70,67,238,63,173,105,125,157,1,205,80,215,127,227,217,62,180,155,185,44,231,213,119,56,21,125,34,72,151,222,170,219,50,172,132,154,115,204,94,79,106,18,37,18,150,218,223,47,21,52,76,88,124,198,170,154,145,15,21,86,53,44,72,216,24,21,66,225,112,114,42,206,226,122,212,50,156,241,73,162,90,43,174,73,197,73,210,128,184,167,0,89,128,20,146,176,146,177,102,217,183,41,6,130,153,126,149,36,17,108,94,188,212,152,239,84,138,33,152,126,235,21,70,76,227,21,98,87,37,177,218,163,198,105,52,38,174,64,9,94,212,185,46,64,29,105,102,60,224,85,187,59,112,0,118,228,246,168,51,176,239,
36,44,99,30,148,248,84,55,4,84,196,113,73,110,63,120,107,68,108,182,23,24,28,10,169,33,203,26,211,42,49,89,178,12,57,161,9,13,3,145,86,118,0,149,28,43,243,100,213,156,113,138,2,229,126,106,120,20,227,38,148,39,97,222,175,165,176,242,199,173,32,43,98,148,83,229,64,135,25,168,233,136,83,200,168,192,237,218,164,162,128,51,174,99,10,249,20,216,84,51,1,86,110,211,43,187,210,163,182,81,215,189,5,14,104,65,53,89,192,14,64,171,115,73,176,125,106,153,57,52,208,209,28,128,130,24,85,168,229,221,29,71,128,87,20,197,27,13,34,108,74,105,166,148,28,210,227,52,1,25,168,170,118,24,83,85,232,0,106,69,7,131,75,214,166,65,181,112,104,21,174,89,71,200,0,250,84,47,112,124,224,6,49,77,7,138,170,205,131,67,19,208,208,149,67,174,225,85,233,33,144,236,35,52,170,11,54,41,162,211,208,70,201,28,84,208,22,35,7,160,169,62,202,118,231,52,42,237,24,161,131,29,65,233,69,24,220,180,132,67,31,205,33,171,74,185,28,244,168,161,143,97,38,172,142,148,129,141,218,170,14,5,83,150,66,73,230,172,77,40,80,64,170,100,230,
154,26,64,73,10,78,106,177,231,147,82,204,126,76,10,175,131,138,150,200,155,16,245,162,146,138,200,204,214,47,229,228,45,71,146,231,220,211,204,121,60,154,14,216,198,77,110,110,106,88,160,141,65,245,173,0,107,46,202,95,50,44,254,21,117,101,32,84,180,75,44,213,59,168,143,222,21,42,202,73,169,92,7,76,26,157,132,100,172,155,100,24,237,91,17,16,209,131,235,88,211,68,233,33,224,213,235,57,241,22,27,168,166,245,6,88,154,82,188,10,81,32,42,9,235,85,36,125,205,154,154,56,183,46,73,165,97,88,147,112,35,52,205,224,210,180,127,33,11,89,238,89,24,130,77,52,82,104,150,234,69,60,10,142,62,42,68,137,89,115,212,211,10,237,53,67,37,18,149,28,85,136,100,220,188,245,170,84,170,229,122,26,26,21,141,2,217,20,195,205,71,28,155,199,189,73,83,176,210,19,104,205,59,60,84,126,114,103,25,168,222,117,221,128,105,238,4,229,177,89,218,184,243,45,137,244,171,97,183,12,131,80,94,243,105,39,210,139,18,206,98,156,132,6,4,210,30,166,142,180,25,245,44,117,230,156,166,165,182,136,58,229,141,71,62,209,38,23,165,81,
178,16,184,168,201,205,20,141,128,189,105,54,38,195,34,167,179,1,165,21,71,38,175,233,249,76,179,14,189,42,84,174,74,101,231,92,17,76,52,51,228,212,102,85,223,183,189,89,66,52,42,78,105,62,206,181,45,88,130,3,39,39,129,64,204,232,236,192,124,177,207,181,91,3,111,65,87,190,194,115,242,145,138,137,173,138,183,38,164,146,171,100,46,106,59,103,253,233,247,171,151,17,19,22,22,179,208,21,152,10,162,209,163,212,85,41,227,1,234,234,142,51,84,174,203,7,207,106,4,48,113,210,165,89,57,193,170,193,253,105,85,179,64,23,226,108,48,36,113,90,73,42,149,6,170,218,70,179,91,128,122,250,212,191,100,192,251,198,165,136,101,198,210,195,21,13,18,48,82,70,115,138,139,204,203,0,41,129,97,83,34,131,29,57,79,2,150,152,200,100,135,122,144,106,164,104,209,185,83,210,180,169,142,0,82,113,64,20,38,77,216,205,64,98,230,172,187,102,153,64,92,132,40,20,215,90,144,140,84,114,30,40,24,197,98,42,64,220,84,52,51,30,148,3,21,164,39,35,181,71,69,39,122,9,30,139,147,147,82,226,145,72,199,6,167,72,29,198,64,226,129,
162,44,84,18,91,191,81,210,173,60,108,141,134,21,48,192,78,104,98,146,185,155,24,32,250,85,203,70,1,249,25,165,34,55,233,77,242,74,156,169,160,22,134,136,35,165,80,158,225,35,108,96,154,99,52,170,167,25,205,81,98,73,57,235,74,226,110,197,216,39,50,205,142,130,174,237,21,78,210,220,167,206,221,197,104,71,19,200,50,163,138,1,17,129,138,71,125,170,106,99,3,142,213,19,198,122,17,65,69,9,27,45,76,205,88,154,19,212,10,175,140,26,161,161,84,100,243,67,129,233,74,163,154,28,100,210,6,68,234,54,30,5,20,147,54,6,1,162,179,150,230,78,215,52,37,125,138,77,83,121,25,250,154,179,119,149,92,26,167,90,26,26,122,116,234,171,176,245,205,104,131,154,197,178,81,184,183,113,90,43,35,14,244,8,178,101,242,207,74,154,59,149,97,207,21,69,164,47,129,79,78,41,52,5,214,242,156,18,64,170,216,10,78,222,148,185,197,38,104,72,2,165,89,153,83,21,9,32,117,56,166,9,84,182,1,161,129,104,92,17,215,154,165,52,155,220,154,149,152,5,170,199,147,69,130,196,137,51,47,2,156,28,177,249,170,53,90,157,99,24,166,49,180,134,
156,70,208,73,168,247,130,113,64,19,69,38,194,120,205,72,110,58,241,76,142,60,242,122,84,158,90,250,82,176,138,197,137,36,210,96,147,197,78,208,130,120,226,158,177,168,232,41,128,212,82,171,80,94,56,48,186,250,138,178,204,20,114,106,141,211,2,167,222,129,152,230,33,147,214,145,80,15,122,145,248,108,82,236,52,10,200,18,70,65,128,105,164,228,228,209,73,140,230,134,54,68,100,57,166,51,19,214,149,212,169,230,154,69,100,238,100,217,53,188,30,97,201,224,85,213,101,76,40,20,144,168,88,134,61,42,57,27,13,197,92,81,113,69,140,211,124,177,191,61,234,17,41,2,166,137,247,156,119,170,42,197,136,226,103,32,1,199,122,208,141,66,0,42,75,107,112,177,131,142,105,90,50,15,74,73,138,227,209,241,214,146,72,131,13,194,163,60,117,166,27,229,69,32,174,105,52,43,12,113,128,115,89,96,102,126,58,102,172,77,122,205,144,6,42,170,57,86,205,81,72,209,29,42,25,227,86,94,122,211,18,115,158,105,236,219,186,80,5,17,9,207,181,74,33,0,84,216,166,74,112,188,80,23,52,52,215,80,133,51,206,106,236,141,181,24,231,160,
172,11,121,154,57,1,7,30,181,163,115,120,173,14,212,60,158,181,45,1,73,223,44,105,240,46,249,7,181,64,78,77,93,177,79,148,182,41,136,155,203,192,166,146,70,106,193,21,90,124,131,245,166,2,35,156,243,75,43,141,132,84,52,142,73,20,128,136,138,105,90,147,105,199,74,74,0,99,39,25,170,110,121,197,95,110,86,168,56,249,141,49,161,184,164,97,147,83,34,113,147,81,145,205,50,132,42,49,76,171,139,109,152,139,19,205,83,60,26,68,177,87,57,192,171,241,92,148,64,184,233,89,234,112,115,83,43,102,128,68,210,204,100,108,145,76,121,206,221,160,83,106,55,235,64,199,43,98,164,73,88,182,42,190,106,120,23,57,52,1,99,130,57,21,86,107,124,29,200,63,10,181,210,142,180,137,104,32,102,242,192,113,205,106,90,16,99,192,237,89,131,138,154,27,134,139,167,34,128,216,211,125,170,50,216,2,169,202,21,152,149,233,84,165,188,158,238,79,45,62,85,7,173,92,65,133,0,242,105,128,195,16,106,206,150,61,174,69,106,57,216,185,21,159,49,221,33,56,160,104,128,14,105,28,96,19,79,197,50,99,132,250,208,54,202,173,201,201,162,138,
43,54,140,25,161,125,40,146,76,47,65,85,112,125,42,208,136,6,201,167,148,4,116,173,13,136,172,223,107,237,245,171,227,165,85,72,194,182,71,90,210,129,86,72,112,58,138,4,65,210,148,62,8,167,109,218,216,106,123,70,10,228,80,3,12,188,251,83,90,237,21,73,199,74,175,33,108,145,138,140,198,89,79,106,6,13,120,211,191,76,1,83,68,107,60,43,194,217,34,174,219,72,29,79,181,2,44,22,38,128,121,164,167,199,25,118,227,181,32,30,6,71,74,145,27,177,169,138,141,155,70,42,185,82,175,140,80,2,206,127,119,84,129,193,21,102,85,145,206,2,241,85,138,144,105,129,165,11,134,65,205,62,169,69,111,38,220,131,248,85,212,82,20,3,214,144,6,64,164,220,167,128,121,164,147,133,53,84,54,14,105,128,178,100,18,9,172,233,238,65,114,61,42,243,30,164,214,77,192,2,86,164,3,119,111,146,166,115,129,80,71,193,205,74,50,196,83,26,25,130,123,83,146,50,199,218,172,170,224,116,167,244,29,168,11,148,46,32,33,134,42,184,92,184,95,122,184,238,29,170,20,143,247,160,212,180,67,137,113,70,20,15,65,80,184,221,37,78,57,52,230,136,40,
205,82,45,21,252,174,42,205,132,35,207,82,199,138,102,42,205,170,29,193,187,80,198,205,196,192,29,104,96,164,117,170,66,66,5,47,152,77,71,41,157,135,92,254,237,9,172,137,36,7,34,181,29,139,174,13,80,158,221,247,101,65,57,170,69,20,207,90,20,83,202,144,112,71,52,83,24,130,172,199,247,106,20,92,156,85,145,192,197,33,21,230,114,167,138,137,152,181,77,112,185,21,0,28,83,24,218,112,110,105,13,53,137,2,129,147,14,107,87,78,95,221,144,65,21,157,167,21,146,112,13,111,162,5,28,84,201,144,217,12,139,131,85,46,58,129,90,36,3,84,238,144,22,24,60,208,152,20,232,3,52,173,242,154,65,76,98,158,149,17,169,24,228,84,116,0,103,181,64,209,101,137,169,169,24,224,83,2,18,48,106,61,153,111,198,165,110,180,138,112,65,160,162,226,160,41,143,106,205,185,132,196,255,0,90,190,38,202,240,42,181,215,204,185,52,8,172,128,28,230,158,6,41,145,131,154,144,208,49,42,55,251,213,38,9,53,27,2,15,52,0,177,71,188,226,174,196,155,23,21,94,21,218,51,86,151,165,2,17,133,68,207,182,172,109,220,166,168,205,184,55,52,2,44,
3,145,154,112,170,130,66,6,42,88,229,7,175,90,2,197,168,148,35,113,86,119,15,90,170,167,138,105,39,52,8,177,44,139,140,117,170,50,244,38,165,205,69,54,118,113,64,16,35,224,243,81,220,28,226,151,189,54,94,212,4,182,34,193,34,138,144,12,10,42,26,33,68,211,197,20,185,20,149,101,139,140,212,176,72,98,106,96,20,187,115,72,9,157,247,156,209,191,229,197,48,116,166,154,0,66,57,164,168,229,147,101,66,103,99,235,78,195,45,50,134,24,166,197,16,143,56,239,81,67,35,49,231,53,109,70,105,9,137,222,134,153,162,94,9,20,164,98,162,155,238,208,4,246,50,151,148,238,36,213,198,11,188,18,69,80,211,129,243,13,62,237,89,95,61,169,140,158,89,134,112,13,67,145,154,142,52,249,119,102,148,80,5,216,228,80,57,52,253,235,180,144,69,103,49,230,141,199,212,210,17,35,202,73,228,210,2,49,81,210,140,211,1,88,230,178,174,127,215,53,105,30,56,172,235,161,137,104,2,52,235,86,224,79,147,53,86,48,75,1,138,209,69,194,129,72,4,20,217,70,80,226,164,219,80,78,216,227,52,208,110,81,32,171,84,131,181,7,154,41,141,34,196,109,
156,85,166,1,147,222,169,69,210,175,66,62,78,105,48,34,8,122,213,155,86,207,203,81,72,192,47,90,129,36,42,252,19,64,236,106,228,122,210,18,51,214,160,86,200,165,205,2,39,82,1,201,53,38,244,219,147,85,51,72,220,138,66,32,152,239,144,144,42,34,190,213,54,48,104,198,104,1,176,175,53,53,53,5,73,192,160,8,153,42,38,90,157,220,99,2,161,52,1,9,83,76,97,86,56,166,148,6,152,199,233,113,177,186,7,28,86,181,205,216,132,133,234,107,46,18,98,108,173,36,142,89,178,79,53,54,184,139,13,122,231,63,49,230,136,165,46,14,78,106,157,90,181,140,242,72,226,157,128,38,206,115,77,83,154,178,202,15,90,133,163,231,138,96,60,192,194,61,213,89,220,41,193,60,214,172,88,104,118,247,172,59,168,221,39,35,222,146,4,74,91,2,155,156,213,114,239,198,115,82,169,37,69,49,216,82,40,2,138,114,138,0,81,210,155,34,238,92,83,241,75,72,69,82,49,77,238,106,203,166,123,85,105,70,197,36,211,29,198,194,229,231,3,181,58,113,243,213,104,92,164,128,213,249,151,49,228,245,164,133,22,54,50,48,57,171,3,165,82,132,252,226,173,230,
153,68,170,216,166,76,130,79,173,3,154,117,33,21,26,221,128,205,70,1,12,1,171,245,20,177,131,147,197,48,28,140,48,57,167,17,154,163,146,15,6,173,196,75,45,22,6,133,41,233,81,177,7,138,149,206,213,36,213,18,231,113,52,0,72,155,77,71,32,202,211,217,179,214,147,218,128,122,145,41,38,138,144,140,47,20,81,97,37,99,109,109,192,234,42,23,77,175,140,86,156,234,1,226,171,75,9,100,221,131,74,224,84,20,187,128,28,154,67,197,12,153,143,61,233,140,80,192,244,52,214,144,45,86,36,131,65,36,208,22,18,121,55,28,83,97,219,130,90,145,198,106,69,69,219,76,100,177,186,103,2,173,132,32,100,138,165,111,22,251,133,11,235,93,18,66,165,0,34,162,78,196,201,153,36,83,150,48,195,145,87,164,181,93,220,14,42,54,139,111,74,19,11,144,160,219,211,138,87,27,186,243,75,140,82,51,5,4,154,96,70,202,17,8,168,115,76,50,150,110,105,212,192,113,164,197,40,52,82,1,49,83,33,85,66,120,162,40,183,242,105,179,66,83,215,20,192,137,206,227,154,206,185,7,205,171,245,70,231,253,112,160,4,140,236,34,174,68,225,133,82,171,22,234,
64,201,160,166,88,99,129,154,161,35,110,115,83,220,77,242,237,6,163,130,45,252,154,4,137,35,132,21,30,180,201,97,218,120,171,106,0,21,20,235,158,104,184,92,72,34,27,114,212,233,37,0,109,90,131,121,3,25,164,201,52,192,113,37,141,88,138,53,3,36,115,80,195,212,213,158,212,128,145,113,75,76,83,138,144,2,123,80,1,78,192,218,105,188,142,212,215,56,20,132,70,122,211,88,240,113,75,80,201,40,70,197,2,24,179,178,54,24,212,193,247,116,53,25,69,149,115,142,106,19,186,22,29,113,76,101,188,211,75,12,245,170,210,92,19,194,156,82,70,196,138,0,157,207,65,79,81,129,80,100,212,241,242,180,12,125,33,66,199,129,154,114,128,72,21,179,111,4,97,6,20,125,106,91,177,45,216,169,101,100,54,238,145,121,171,114,64,54,252,162,172,1,129,197,13,210,162,228,220,202,113,180,243,77,21,53,215,45,154,130,180,69,143,18,108,231,56,168,223,231,57,34,160,187,82,83,35,181,71,111,114,73,218,216,160,9,101,132,63,106,174,203,180,226,175,3,85,238,23,230,6,152,200,41,86,146,148,117,160,9,105,41,194,128,165,155,2,144,134,213,
75,226,112,0,233,90,95,103,227,189,80,187,225,241,233,64,90,229,5,7,120,227,189,105,202,167,202,252,42,188,42,26,81,197,93,156,98,44,81,107,2,86,41,32,195,213,154,174,56,53,118,36,12,160,211,40,88,54,134,249,135,20,173,140,156,116,164,124,14,41,25,128,92,154,4,45,69,55,220,56,164,51,140,118,170,236,229,223,25,224,208,129,11,18,111,122,188,170,0,227,21,6,229,130,49,140,102,171,181,212,155,143,52,48,100,247,164,140,85,42,115,72,210,28,177,205,55,167,90,0,90,74,98,190,91,20,74,216,224,82,108,92,196,234,129,150,138,108,7,16,150,205,20,92,46,116,69,137,234,106,204,100,52,99,210,179,47,153,163,194,131,86,172,100,204,2,147,65,97,103,182,86,25,28,26,133,98,0,96,243,83,93,207,229,174,7,83,84,188,230,199,90,104,10,247,17,108,108,246,168,182,159,74,209,9,230,199,243,84,139,18,129,208,83,29,204,130,190,212,161,73,233,90,111,108,140,121,21,34,66,138,184,2,128,185,22,151,1,243,119,48,233,91,35,165,81,141,196,99,56,167,125,181,127,187,89,201,93,144,213,201,110,165,242,147,56,205,84,55,128,169,
202,243,75,52,190,114,0,70,42,140,138,84,227,60,83,72,105,22,4,161,186,213,107,153,179,192,233,76,39,138,132,242,121,171,40,51,205,78,135,43,80,98,158,175,182,128,38,205,40,168,132,132,212,139,72,69,200,28,109,193,167,204,3,71,154,165,156,119,169,4,173,183,20,1,27,1,89,247,3,247,166,174,73,54,222,0,170,50,54,230,38,153,72,88,113,187,230,165,154,99,247,87,129,81,103,138,116,81,135,57,52,193,145,31,122,114,72,203,247,78,42,118,133,77,69,176,6,164,33,235,114,227,173,49,229,103,234,105,174,184,230,155,64,172,58,18,205,48,30,181,113,163,81,77,181,140,42,238,239,82,30,104,1,170,48,56,169,80,241,81,129,86,18,47,221,238,205,3,22,28,111,25,171,200,57,233,89,241,48,105,66,251,214,170,128,5,32,35,145,6,50,5,66,200,27,130,42,219,116,168,72,161,1,70,104,246,31,106,204,156,254,240,214,180,236,75,144,106,141,204,59,190,97,197,49,14,181,32,198,5,58,117,13,25,227,154,167,12,141,27,96,85,241,200,160,12,245,132,231,44,42,76,1,197,92,43,154,130,88,241,200,160,17,13,88,183,5,142,5,64,106,197,148,
155,102,3,214,129,151,45,237,242,217,126,213,173,14,2,129,85,148,113,154,149,91,2,162,68,180,76,205,129,85,158,66,79,90,87,98,105,159,206,132,132,149,136,39,108,46,77,85,105,148,85,155,165,221,17,246,172,163,156,213,150,92,44,174,135,61,43,56,241,48,35,142,106,97,55,200,86,160,110,24,26,0,213,67,242,138,130,224,252,194,164,133,195,70,13,65,43,238,126,148,1,29,42,131,214,156,139,158,77,73,210,128,19,56,197,75,19,85,51,33,50,1,86,163,60,80,5,129,39,173,101,93,54,233,152,213,247,229,14,43,46,79,188,104,64,137,109,127,214,138,183,113,254,172,214,98,72,81,183,10,146,75,135,144,114,120,160,5,53,106,217,248,197,82,67,83,193,159,48,83,25,101,163,44,217,205,36,209,51,46,1,171,11,65,192,169,36,206,120,29,78,5,55,201,113,212,126,149,181,108,138,91,39,154,146,91,101,57,32,211,184,238,115,197,92,156,28,212,171,104,88,18,79,53,125,144,3,140,10,80,49,64,138,113,218,40,7,36,147,84,38,206,242,190,149,183,84,174,80,7,200,20,129,234,82,138,62,114,105,39,0,99,21,104,39,203,146,106,2,50,220,208,214,
129,203,161,95,115,1,140,241,69,91,242,210,68,192,24,52,86,118,100,89,154,218,153,204,128,123,85,88,167,146,33,133,108,85,221,70,18,199,120,172,218,209,108,106,137,37,157,228,57,115,154,187,102,155,226,7,109,101,49,231,21,189,98,84,219,174,220,80,196,196,3,20,85,134,85,29,106,156,251,135,220,160,66,73,56,86,219,138,86,156,0,49,214,169,57,36,229,186,209,147,222,129,151,36,149,74,123,212,32,247,168,55,227,169,167,131,197,2,36,105,143,65,210,163,36,147,147,73,71,74,0,141,201,205,48,12,211,159,147,78,80,49,76,98,4,226,162,112,219,241,218,172,83,8,201,160,5,3,165,18,73,229,174,123,208,120,25,170,114,57,103,231,165,33,26,17,49,145,65,34,159,140,83,97,219,229,141,190,148,179,72,145,38,88,211,2,156,249,222,106,18,42,222,232,231,25,83,205,64,192,41,198,105,148,153,14,42,120,134,22,155,180,19,82,168,192,197,32,108,90,133,135,205,83,129,76,116,57,226,129,21,222,150,21,82,255,0,48,226,135,4,30,105,128,226,129,154,10,84,174,5,24,170,144,203,183,173,90,86,12,185,20,8,81,83,60,193,96,218,58,
154,138,162,144,243,214,144,18,90,141,215,11,245,173,161,210,177,236,0,243,183,19,192,21,176,8,219,214,144,12,115,206,42,55,109,139,186,165,198,78,106,164,239,146,84,30,41,129,3,157,199,52,199,31,41,165,46,163,171,10,99,206,131,60,228,208,6,113,226,79,198,175,199,40,32,1,84,164,33,155,52,43,21,228,26,171,14,198,141,33,0,138,163,231,190,122,213,196,109,200,13,34,74,210,12,53,69,36,173,22,10,240,106,89,216,6,198,105,138,139,55,6,134,55,176,255,0,237,123,129,30,1,3,222,146,61,90,225,51,150,221,245,170,147,196,98,111,106,138,179,50,187,52,255,0,182,103,255,0,103,242,164,254,216,159,253,154,206,20,180,211,11,178,231,246,140,236,126,102,200,53,39,222,31,81,89,217,169,162,149,201,218,13,82,99,82,31,229,178,201,199,74,123,130,71,20,226,105,64,201,166,104,145,45,179,148,24,52,233,136,221,197,6,45,170,8,168,201,57,160,9,86,78,212,246,111,147,53,92,113,82,33,200,32,208,34,182,126,124,213,180,60,102,171,60,100,28,138,154,12,227,6,153,67,228,114,177,156,85,7,53,160,201,189,113,84,46,99,104,
206,15,74,66,189,136,233,64,166,175,122,120,56,227,20,9,10,6,5,73,28,133,27,52,195,74,7,20,203,45,165,216,254,42,107,78,101,144,1,192,170,149,53,187,5,124,181,2,104,211,133,153,58,26,145,174,92,140,85,69,185,139,118,51,205,61,142,239,184,69,73,35,179,154,41,177,171,103,154,147,20,192,110,64,25,53,12,187,88,84,147,28,12,84,20,128,110,6,42,23,135,57,34,172,85,105,110,182,73,128,58,80,13,216,134,60,199,38,13,20,198,155,116,155,241,69,4,166,117,50,0,202,67,86,53,192,84,114,23,165,77,60,197,220,213,73,142,77,51,68,68,79,53,122,206,238,68,27,71,74,161,86,173,199,203,248,211,27,53,18,231,127,222,52,201,102,0,227,25,170,221,42,84,139,116,121,239,82,74,33,145,131,55,3,20,199,112,171,205,72,98,113,216,226,170,76,73,56,193,166,128,105,144,187,10,182,189,5,65,111,17,45,184,138,180,177,146,112,189,232,96,198,211,25,141,91,251,43,4,36,154,172,203,205,2,35,169,34,66,231,128,105,155,13,106,89,66,190,71,185,164,221,128,168,208,228,113,80,178,21,235,87,157,112,72,164,242,76,171,192,160,10,12,50,
57,168,90,37,34,172,203,25,141,176,213,82,73,14,113,76,105,18,71,43,71,198,105,147,49,148,96,154,143,117,56,116,205,1,98,185,243,33,63,41,52,36,185,111,156,213,180,85,127,189,81,220,90,133,77,201,218,145,14,232,116,108,133,134,24,85,140,86,66,177,86,200,171,214,183,27,219,107,117,160,20,139,52,12,83,252,178,122,213,103,147,107,226,130,247,25,113,247,170,26,146,70,222,115,233,85,139,156,211,6,236,75,210,173,91,18,87,158,149,4,49,25,20,19,210,174,40,218,49,64,94,226,212,78,57,165,150,101,143,175,38,160,55,59,186,138,64,74,174,201,247,73,21,161,111,120,187,49,35,224,138,198,105,137,60,116,166,238,38,152,27,51,234,104,168,68,124,177,172,227,119,33,36,231,173,87,205,2,139,1,33,149,152,228,154,77,196,211,89,194,210,168,45,210,129,166,133,198,123,210,54,213,31,49,164,120,103,39,42,135,242,168,94,41,65,249,212,138,151,38,75,147,45,219,170,72,73,244,171,103,229,67,182,171,105,145,254,240,134,61,171,85,99,11,77,48,185,142,209,74,228,182,211,79,134,218,96,217,193,21,174,16,82,129,138,96,
81,107,31,61,14,238,15,106,204,185,179,146,216,229,135,21,209,228,1,205,103,234,160,203,8,35,181,67,68,180,98,85,139,91,102,184,124,14,23,185,168,99,79,50,69,95,90,222,183,137,32,140,40,57,164,145,41,21,100,210,208,0,84,154,174,33,88,143,78,107,99,239,116,170,119,112,149,249,133,90,69,164,138,153,165,94,180,152,171,48,198,49,147,76,182,76,20,188,96,123,85,103,82,167,154,186,131,142,5,71,113,25,242,201,197,4,149,51,74,167,28,212,113,242,216,171,62,95,20,12,84,143,120,201,169,4,74,58,82,175,20,234,0,64,160,84,87,17,163,140,17,86,20,22,226,153,50,16,69,33,25,173,10,198,120,239,77,218,51,86,39,7,60,212,52,202,66,83,182,141,166,155,79,94,148,1,9,20,160,226,158,203,154,65,27,122,80,5,86,118,15,144,121,169,99,188,150,62,249,168,31,135,52,149,139,122,152,223,83,74,61,76,241,185,106,236,51,164,227,42,121,244,172,56,212,57,53,114,196,24,229,39,218,174,45,148,155,47,78,121,21,22,105,242,29,199,35,210,179,90,118,19,124,221,1,167,123,20,217,117,142,213,45,233,89,142,197,152,147,222,172,75,
114,100,27,16,112,106,35,111,38,51,182,139,144,221,200,168,167,172,76,95,110,48,77,20,19,99,72,231,52,199,93,212,246,35,113,164,61,9,170,54,43,178,133,56,171,118,227,9,84,29,178,217,171,240,56,49,138,2,229,132,66,198,173,68,157,5,83,86,193,200,173,11,110,87,52,152,18,20,24,197,87,107,72,216,146,87,245,171,70,155,66,2,140,177,172,109,133,165,183,63,189,25,169,230,139,127,35,173,37,188,37,78,230,160,65,117,38,197,218,7,90,160,199,191,74,183,124,224,252,163,173,102,220,183,238,168,67,38,24,61,57,171,176,72,99,76,86,110,158,164,228,158,149,162,58,83,16,172,73,60,212,145,73,183,138,138,149,70,230,192,164,3,175,33,87,140,184,56,32,86,44,145,145,205,108,207,27,136,137,53,158,200,88,96,80,134,138,99,173,76,23,138,107,68,193,186,84,130,168,109,130,174,42,27,171,158,60,177,207,173,79,218,179,101,206,243,159,90,150,103,38,50,167,180,31,191,4,244,21,15,94,0,171,48,161,65,205,34,98,174,105,60,170,19,131,89,238,114,196,211,137,52,210,42,145,178,208,105,56,21,93,134,13,76,221,106,41,58,208,
200,153,98,218,224,40,8,122,122,213,229,231,220,86,56,25,32,10,213,139,132,25,244,164,40,177,178,196,140,114,78,13,82,144,0,228,14,148,147,57,50,147,75,215,20,33,167,113,180,185,20,245,137,164,63,34,147,244,21,52,54,50,179,124,224,168,160,101,126,13,77,29,172,210,31,149,15,227,90,48,218,162,99,28,253,107,77,16,5,20,238,51,33,52,114,227,46,248,246,21,58,89,164,88,24,233,239,90,44,219,69,86,39,38,146,16,208,49,210,170,222,192,30,34,195,168,171,116,132,100,98,128,48,224,118,138,77,194,182,161,112,241,134,172,187,184,76,114,118,230,173,217,74,12,123,105,129,118,156,5,70,173,147,82,110,226,144,13,126,120,172,237,74,113,20,126,88,251,205,90,29,107,15,81,39,237,124,251,82,98,100,94,75,194,171,47,227,90,86,247,2,84,28,128,213,20,169,230,65,129,215,21,65,55,194,249,197,36,78,198,236,108,65,193,167,77,31,155,30,7,90,167,111,116,147,97,122,53,93,103,88,98,44,199,129,84,85,202,102,217,80,102,73,2,253,106,69,216,87,228,57,21,149,119,114,103,144,183,65,233,86,108,11,20,57,233,74,225,123,154,
144,140,45,19,31,148,143,90,137,100,42,49,74,91,60,211,25,73,99,43,41,171,3,165,13,214,133,20,198,197,165,13,206,13,46,56,166,30,180,132,79,27,96,212,248,200,170,169,206,49,86,133,48,51,111,83,18,113,85,123,213,187,183,15,39,29,170,163,228,2,104,25,27,200,16,226,164,66,10,228,85,38,206,121,171,86,223,112,210,185,42,87,100,160,243,205,76,15,30,213,91,189,76,14,22,153,108,173,37,176,102,36,53,87,104,153,79,76,138,186,105,202,132,246,169,113,33,196,207,140,237,110,149,114,7,10,212,245,181,14,114,120,252,41,30,2,167,138,18,176,226,172,88,103,11,25,98,120,197,100,187,110,98,125,77,88,184,44,168,1,170,233,214,166,91,145,34,197,162,224,22,53,56,151,146,13,85,71,43,82,30,181,105,23,20,74,72,222,8,162,162,94,162,138,99,177,40,108,55,52,178,49,41,129,77,142,25,11,18,194,156,202,84,224,208,5,117,67,187,154,157,78,56,20,81,64,203,80,100,175,173,106,219,12,68,5,103,105,231,13,140,117,173,25,9,9,242,245,164,196,76,122,82,98,179,222,73,71,82,106,204,83,174,193,185,185,165,96,39,197,21,26,204,
140,122,211,100,184,69,206,15,52,1,78,247,253,109,83,153,11,38,5,89,149,252,198,201,166,40,27,135,165,48,36,178,183,120,224,203,12,115,82,116,124,102,174,132,223,8,11,89,243,3,25,110,121,20,92,68,217,169,224,76,29,198,177,45,222,86,155,36,156,86,213,172,155,151,4,231,20,48,34,189,148,227,103,52,182,158,91,32,24,25,21,52,176,44,189,71,52,177,70,145,12,12,82,25,28,246,202,202,72,3,53,148,235,181,136,173,198,117,11,146,107,22,102,13,35,17,235,77,0,204,224,85,89,35,14,249,21,97,186,84,14,219,84,145,76,76,138,18,18,99,145,86,24,228,241,84,131,29,217,171,168,50,160,154,5,17,185,162,156,86,155,222,130,200,155,134,167,42,43,47,35,154,71,28,211,226,141,184,56,226,129,49,145,196,203,46,72,226,172,228,138,74,51,72,73,20,138,150,144,224,30,77,89,75,119,103,81,140,102,167,132,15,48,100,85,213,192,96,125,232,18,86,44,193,2,198,128,0,1,197,61,212,109,224,83,212,228,102,156,5,5,16,71,17,39,39,138,178,58,80,7,20,26,144,25,42,229,106,190,57,169,229,108,47,21,18,227,21,72,6,17,138,41,207,235,81,
25,20,30,180,196,87,190,139,114,22,29,170,141,156,161,102,193,61,107,74,87,12,133,71,165,98,56,40,231,177,205,0,217,190,189,51,154,112,32,214,93,188,140,209,242,196,212,234,228,119,164,5,169,36,218,48,43,54,104,4,146,239,60,213,146,114,115,76,145,213,0,220,113,154,76,0,116,170,147,12,57,171,99,4,113,80,220,14,50,5,52,8,167,147,27,135,28,115,90,114,74,183,54,187,21,190,106,207,43,145,138,108,78,98,148,100,224,82,98,106,197,168,45,130,33,50,1,245,53,98,34,184,194,16,126,149,78,238,232,72,2,161,226,157,96,27,6,129,34,240,235,67,62,5,37,33,4,211,40,3,3,79,74,135,7,53,50,140,10,0,119,106,140,242,105,219,135,173,62,45,164,208,4,112,182,36,230,174,49,249,14,61,42,164,203,181,243,82,6,59,58,246,166,5,7,63,49,205,32,233,68,135,110,73,53,88,204,216,198,104,11,137,62,221,252,10,146,28,109,199,122,129,121,60,212,168,121,226,144,146,37,97,73,187,20,49,164,166,89,34,115,86,16,128,42,160,60,245,171,43,141,162,129,50,94,41,134,138,41,8,165,112,166,71,219,81,73,17,139,0,142,181,98,99,137,69,73,
36,126,114,174,49,69,132,209,90,222,18,236,24,142,5,73,56,1,184,171,36,8,226,227,181,83,60,154,99,136,177,169,102,24,20,84,192,136,98,44,122,209,74,224,217,115,21,82,99,151,171,117,78,65,243,154,99,67,84,100,212,193,71,165,49,6,13,72,217,24,160,101,139,85,62,102,64,226,180,85,129,226,171,198,85,97,24,244,165,136,157,226,144,137,39,140,188,124,14,106,145,134,65,252,38,181,41,113,197,43,129,140,119,47,92,138,50,107,85,160,71,234,181,90,123,101,94,64,167,113,20,168,21,49,136,80,177,129,76,13,24,56,136,1,233,84,46,87,18,28,213,219,102,200,11,233,80,223,129,191,240,168,234,5,21,0,116,226,166,130,64,140,106,33,214,172,34,129,218,168,101,232,242,233,145,85,38,71,86,201,205,94,183,92,32,165,184,64,80,228,84,223,82,111,169,148,196,149,60,213,35,214,180,163,8,217,82,41,179,64,162,51,181,121,171,25,156,122,85,59,134,254,26,179,59,249,124,119,170,103,158,77,0,201,32,132,50,238,53,108,0,42,172,4,238,199,106,181,72,73,88,42,22,224,212,212,140,153,25,166,82,33,224,212,169,38,0,21,90,73,10,54,
49,66,77,189,177,138,87,11,162,196,174,15,11,72,58,84,75,247,169,100,126,48,41,140,71,144,134,249,79,74,209,129,247,198,13,103,199,22,121,53,97,73,81,197,2,52,99,148,169,28,241,87,163,249,148,26,199,133,201,235,90,150,173,152,170,88,137,73,166,147,74,122,211,77,8,100,115,30,5,68,27,20,76,255,0,54,41,181,64,36,141,145,201,168,15,181,75,39,74,142,128,27,84,47,226,32,7,2,180,41,146,160,145,10,154,76,77,25,182,146,237,36,19,214,175,102,178,92,20,114,61,43,66,217,203,197,207,106,136,178,98,250,22,1,205,83,212,62,242,85,165,235,84,238,220,201,112,170,59,85,49,178,212,57,17,174,125,41,92,101,77,60,15,148,125,40,81,205,62,131,51,60,194,28,134,168,228,125,199,138,150,249,2,205,199,122,173,89,182,102,217,44,93,107,66,205,78,210,125,107,62,1,186,64,61,107,94,37,1,0,21,104,184,236,58,156,56,168,166,44,7,203,79,95,187,76,161,220,81,212,83,3,100,211,251,83,17,27,14,105,232,118,243,73,193,239,72,231,210,128,31,44,161,128,20,43,98,51,244,168,105,227,238,26,0,204,149,203,185,250,211,89,8,237,
86,12,35,126,105,179,240,153,20,130,196,64,96,84,136,59,212,74,219,184,169,151,52,198,133,164,169,161,80,65,205,49,151,15,138,101,17,100,3,205,79,12,139,159,188,42,189,194,99,145,154,138,53,46,225,105,51,55,45,77,64,65,28,82,213,105,31,202,80,171,79,128,146,50,77,33,139,36,91,185,199,53,28,47,177,182,147,86,106,148,255,0,235,51,64,23,24,134,24,205,68,177,0,221,42,24,114,92,114,106,121,229,242,227,227,27,141,1,123,21,175,31,44,16,81,77,137,114,75,30,104,165,98,109,115,93,134,9,21,12,208,144,55,213,242,138,78,72,230,170,222,73,242,237,3,142,245,69,20,254,148,226,197,134,51,76,136,101,240,122,86,141,189,178,73,201,232,41,48,18,217,24,199,154,177,9,195,243,86,84,42,46,0,226,160,80,26,98,105,92,11,20,225,210,144,83,243,197,75,6,70,210,5,56,53,28,140,29,13,19,68,89,178,13,51,200,192,235,84,128,174,104,165,35,6,140,85,1,110,205,70,51,222,170,106,39,247,196,123,85,139,98,69,82,188,108,206,213,54,212,86,212,128,28,19,83,195,47,204,1,170,245,36,3,50,168,247,166,202,102,228,95,116,81,113,
254,169,177,233,78,140,97,69,46,51,89,25,117,49,80,148,155,6,166,146,117,85,62,184,167,106,22,185,249,215,168,172,150,39,36,19,90,45,77,22,165,73,152,188,132,159,90,140,12,154,87,251,198,148,16,160,211,16,228,225,133,89,45,181,121,170,34,98,27,56,20,75,51,72,70,122,84,243,11,152,190,172,9,28,212,146,56,9,84,34,5,70,79,122,113,36,213,162,210,17,240,253,105,168,129,105,93,130,10,96,155,158,148,157,132,218,185,40,228,226,164,88,64,57,39,52,216,176,195,53,56,166,48,3,20,191,74,74,158,221,65,234,40,1,168,10,145,239,91,22,195,17,15,122,165,129,86,224,114,171,131,82,196,76,221,42,174,226,31,147,86,247,12,102,169,74,114,230,132,4,114,54,92,154,85,53,25,235,64,56,53,67,37,32,17,81,20,197,74,14,70,105,31,165,0,67,138,94,5,20,140,185,230,144,140,173,66,48,146,228,119,166,218,77,229,157,167,189,104,93,64,36,136,250,138,201,100,49,182,15,90,139,89,144,244,102,168,233,84,145,115,123,207,214,172,91,75,230,32,29,197,86,114,99,186,221,235,77,141,154,71,165,20,192,220,81,186,169,20,85,191,143,
56,106,160,70,13,104,222,156,198,62,181,158,213,18,68,72,183,6,210,131,0,10,183,20,128,12,26,165,106,62,67,86,35,82,205,138,168,236,82,216,183,214,150,133,20,236,83,25,16,251,244,231,206,195,138,118,40,110,69,49,149,162,147,25,13,82,29,184,226,170,202,0,99,138,68,144,175,20,236,59,22,133,43,182,213,197,66,146,228,138,176,99,14,1,164,34,171,28,115,80,200,225,148,173,44,231,15,142,213,11,240,148,61,129,236,69,157,167,34,173,66,222,103,225,84,234,221,160,249,73,168,76,206,47,82,202,157,134,145,249,32,138,67,214,157,86,104,54,69,222,132,84,118,241,249,97,152,243,83,210,50,238,24,20,10,197,87,98,204,73,169,109,216,140,230,152,209,48,56,52,245,24,160,100,229,248,168,91,158,180,102,140,100,80,49,7,29,42,54,137,221,178,122,83,234,228,88,100,230,134,38,85,11,181,69,21,102,88,134,210,69,20,129,26,18,73,180,98,169,191,204,14,105,204,73,57,52,211,235,76,10,201,242,201,129,87,227,149,144,112,106,136,24,108,213,165,60,80,34,83,59,159,226,52,36,197,90,163,166,0,119,138,64,106,171,146,160,209,
188,211,19,128,40,61,13,22,1,26,227,28,99,52,225,50,145,200,170,140,8,52,187,8,92,209,97,146,76,192,145,182,153,154,101,40,166,34,196,71,0,213,9,185,144,147,86,51,76,101,6,144,202,213,53,175,250,245,250,210,136,55,30,56,169,161,128,35,134,206,113,64,141,101,233,75,81,197,32,97,82,86,76,205,144,93,156,64,199,218,185,201,15,36,214,246,166,118,219,26,231,102,152,42,244,201,53,113,216,184,236,85,99,201,164,235,77,47,207,74,55,103,160,167,114,91,2,156,102,145,62,248,207,173,33,38,133,251,194,161,238,46,165,179,72,78,222,180,45,69,33,59,185,53,183,67,86,236,134,74,197,142,105,148,230,233,68,113,180,140,0,172,94,230,79,86,93,180,1,163,192,31,90,148,130,14,13,90,211,150,56,215,203,198,88,243,156,85,227,111,27,28,149,21,162,52,70,89,133,132,123,207,74,146,219,173,88,185,141,221,194,168,249,106,107,107,85,85,193,235,64,13,141,55,114,122,83,195,128,113,87,60,149,17,224,10,206,148,21,99,73,59,137,50,125,252,84,76,15,38,153,27,97,134,122,85,213,10,233,210,152,204,243,214,147,189,92,54,128,
158,180,214,181,10,9,38,139,129,16,63,45,52,177,52,210,112,105,142,216,232,105,128,226,112,42,50,198,144,146,122,208,41,0,110,38,169,95,167,1,128,171,140,66,140,158,149,78,66,211,156,15,186,40,98,106,229,88,38,242,155,218,150,105,4,146,130,56,166,73,25,141,176,105,163,134,21,157,200,53,87,160,162,146,35,189,1,20,236,86,136,213,21,239,120,140,125,106,135,90,187,124,70,208,189,234,149,103,35,57,110,89,181,60,48,171,214,227,169,172,184,88,171,113,90,54,133,142,115,210,170,59,21,29,139,66,158,58,84,101,128,167,70,217,21,67,20,211,79,74,100,211,4,56,234,106,47,57,169,140,138,65,243,28,211,54,228,212,140,119,28,211,163,3,60,211,184,92,98,70,115,147,86,68,132,46,41,49,77,199,52,128,130,225,63,138,170,72,224,174,5,95,184,86,104,136,94,181,154,202,202,126,96,106,91,34,76,109,90,181,98,1,170,221,234,117,59,122,82,136,162,91,193,235,70,105,208,48,145,112,71,52,215,5,90,172,208,92,212,138,59,212,7,38,147,123,142,134,129,216,154,80,49,239,80,211,75,51,117,167,170,228,117,166,2,82,142,148,
17,131,138,100,133,130,252,163,154,64,201,2,243,83,43,132,140,250,212,17,22,216,55,117,166,74,199,56,20,11,113,230,229,249,247,162,163,72,153,249,162,128,52,219,165,68,199,138,115,28,158,41,146,100,80,4,93,106,202,125,209,85,241,79,18,21,192,160,9,233,87,27,129,52,205,227,110,77,69,246,129,187,24,160,44,105,25,149,71,173,52,92,12,242,42,8,134,252,103,165,79,37,177,60,173,33,14,42,178,96,138,115,47,201,129,73,12,44,160,230,156,195,20,198,64,177,231,173,47,148,123,84,132,226,128,227,214,128,32,32,138,56,245,169,101,193,228,85,86,206,104,17,39,153,180,28,26,146,1,36,141,156,252,181,87,173,105,219,46,216,128,245,164,192,114,101,13,78,146,3,77,3,52,217,16,170,22,94,181,15,82,89,75,89,156,8,194,3,205,96,176,14,121,171,23,82,51,200,119,117,205,87,29,106,210,208,180,180,32,152,42,156,10,35,29,205,44,227,13,154,112,224,84,245,34,218,136,85,73,233,78,17,168,60,82,82,230,170,200,164,144,254,149,11,156,158,106,64,222,180,198,25,233,76,37,168,206,181,106,35,20,75,156,140,213,66,8,163,4,246,
169,102,123,27,122,115,36,140,92,118,226,180,247,12,117,172,125,63,11,15,29,123,213,205,199,20,205,17,51,203,243,124,184,167,69,55,205,147,85,179,74,174,1,193,160,13,84,149,89,122,212,82,219,172,135,34,179,222,114,62,237,79,111,123,176,126,242,166,214,38,214,36,54,128,119,169,81,2,174,41,166,242,22,28,48,38,162,105,206,120,160,164,45,204,230,50,2,213,87,185,145,248,169,10,137,100,5,141,36,200,170,192,47,106,104,10,204,73,60,210,96,154,144,167,52,224,49,84,4,69,48,51,73,208,84,140,51,85,102,111,225,3,154,0,142,105,119,252,160,241,74,136,21,120,164,242,123,211,192,56,160,100,23,113,239,77,192,115,84,43,91,28,98,179,174,99,216,249,236,107,57,35,57,34,197,140,185,59,15,225,87,112,43,34,39,242,220,53,104,139,184,182,231,60,250,83,76,105,149,111,199,239,7,53,86,164,158,95,54,66,213,29,67,37,238,62,4,50,72,21,107,98,56,194,46,5,99,199,35,68,219,151,25,171,150,115,75,52,252,244,239,197,84,88,226,203,165,11,26,144,0,136,77,59,160,170,243,202,10,16,42,205,10,115,73,186,66,69,62,63,153,
115,85,216,96,244,169,237,250,26,96,56,14,105,65,218,104,39,13,205,41,25,25,20,8,122,182,234,118,41,136,49,82,100,82,1,181,86,228,35,112,49,154,178,198,168,56,59,201,160,44,48,69,142,106,84,140,183,176,168,75,144,106,204,18,135,224,245,164,154,37,19,71,242,116,169,36,25,92,212,98,166,3,41,138,162,200,105,193,65,29,41,164,115,82,40,226,128,24,99,20,152,34,165,233,74,6,104,184,92,128,131,74,168,90,167,40,13,46,208,7,20,5,202,228,109,94,42,21,66,205,147,86,36,108,14,69,69,191,158,5,8,104,149,70,213,226,138,85,229,104,160,69,209,24,90,138,97,200,171,6,160,155,168,164,34,44,10,12,101,250,10,90,177,108,202,160,230,128,41,50,183,74,4,92,142,106,195,242,199,20,130,152,238,89,136,97,64,171,113,184,219,84,227,96,69,74,163,36,10,76,69,135,108,98,162,60,212,162,63,122,70,140,231,52,32,43,191,90,109,88,41,154,137,208,138,99,27,72,84,17,75,69,0,48,69,150,24,171,235,242,168,205,69,18,133,27,141,53,223,119,210,144,18,189,194,167,78,105,5,218,178,156,241,84,229,228,230,154,41,88,77,25,215,99,
247,196,250,156,212,3,173,89,188,251,226,170,59,109,90,190,133,94,200,100,206,27,0,118,165,29,5,66,122,243,83,14,130,179,91,153,167,118,20,82,80,42,138,16,154,51,65,28,211,132,120,228,244,160,90,141,12,41,222,96,198,0,168,223,1,184,164,65,150,31,90,68,92,213,178,140,133,220,79,94,213,110,161,128,237,192,171,32,119,170,52,76,141,155,104,168,73,36,230,164,149,139,118,192,168,168,25,36,124,138,113,25,168,215,138,148,115,72,69,102,133,149,183,45,9,116,81,241,32,171,65,119,28,84,19,195,243,96,211,2,212,114,43,242,13,12,121,172,213,18,69,200,230,173,199,35,50,100,142,104,2,66,194,128,115,81,51,170,144,9,28,212,139,211,138,64,41,168,89,65,53,49,224,115,81,208,2,98,144,173,58,146,128,34,96,65,168,46,99,223,22,123,138,180,212,152,200,193,239,67,19,49,79,20,84,183,17,236,148,250,84,85,137,152,81,222,146,138,0,94,188,86,197,140,94,84,124,245,53,157,102,170,211,141,198,181,250,85,197,21,20,36,237,198,5,85,115,183,147,83,201,42,110,193,52,214,81,34,241,86,104,84,119,4,81,19,236,167,155,119,
230,154,177,48,206,69,48,18,71,201,169,33,110,14,105,133,56,166,12,231,2,129,151,1,164,46,5,49,50,7,53,28,159,122,129,88,115,74,58,10,132,243,154,145,34,46,9,166,237,42,216,52,20,83,113,134,230,165,181,82,100,207,97,73,112,65,126,42,205,164,100,71,211,173,103,212,197,45,73,42,68,98,59,83,149,41,248,173,13,8,156,115,154,112,60,83,136,207,20,221,165,122,208,0,105,203,210,153,78,4,1,205,33,15,165,237,76,14,190,180,201,37,11,208,230,128,176,233,20,17,80,8,206,234,114,76,14,115,64,148,51,98,153,68,128,113,69,40,35,52,80,73,116,212,47,201,169,50,51,76,101,164,4,68,115,64,226,159,76,99,64,11,154,42,60,243,90,11,10,136,65,35,156,80,5,76,145,82,197,54,214,25,206,41,74,131,218,163,116,197,0,91,55,99,35,110,106,117,144,56,226,178,197,88,182,147,13,130,120,162,192,93,197,53,134,120,167,134,83,208,211,37,96,138,73,164,50,172,248,82,0,168,131,26,71,112,73,36,212,208,5,35,38,168,9,21,152,160,206,105,142,225,42,96,115,81,207,22,238,64,230,144,16,180,192,241,76,220,2,230,129,11,250,84,55,10,235,
198,13,48,42,220,54,231,205,85,155,160,169,228,235,76,216,24,243,76,109,104,86,60,154,151,181,56,194,55,113,210,158,118,173,77,140,210,177,14,57,160,10,115,159,155,138,110,120,160,98,30,180,233,143,0,10,101,59,25,28,208,34,42,80,72,57,20,226,162,158,138,8,198,41,88,155,22,44,102,102,157,67,26,212,50,12,241,89,214,144,109,59,136,231,181,91,166,90,36,119,12,184,2,162,197,45,20,12,5,72,42,58,67,32,94,51,64,22,98,32,53,50,228,97,129,166,69,34,150,25,53,98,240,112,164,10,6,83,171,49,40,40,42,181,90,135,238,10,96,65,119,106,36,93,195,25,2,168,36,178,91,182,31,56,173,150,251,166,169,200,138,227,4,3,72,155,18,121,233,44,64,175,90,109,103,252,214,210,250,41,53,118,55,89,7,202,114,104,4,199,210,83,194,122,211,92,96,208,49,141,73,77,38,128,73,32,10,0,142,250,220,152,119,129,210,178,171,162,117,6,2,27,210,185,247,251,199,235,89,200,137,13,162,129,75,138,146,71,68,219,36,86,61,1,173,39,190,143,102,20,146,107,44,211,225,93,206,61,42,147,26,101,146,119,114,59,213,216,1,17,140,213,40,217,60,
208,181,160,6,5,105,115,91,139,76,147,133,52,250,99,130,104,17,89,186,26,108,107,150,171,30,94,123,82,109,11,76,98,98,144,174,105,212,80,3,160,92,3,76,185,66,62,106,150,51,138,116,128,50,154,64,101,121,127,54,77,93,18,170,199,199,90,134,88,138,115,218,152,50,120,167,96,177,60,82,146,252,158,42,192,106,170,163,2,165,70,160,9,212,140,211,157,114,56,168,170,68,126,57,164,34,60,17,214,134,25,90,145,176,221,41,24,113,64,21,93,8,233,80,156,230,174,98,144,196,167,181,59,141,50,165,72,139,82,180,64,118,164,197,59,142,227,148,226,138,109,20,132,89,7,154,120,147,142,106,85,129,71,90,130,69,218,216,29,41,8,70,57,166,183,74,90,70,7,20,12,106,253,225,87,26,224,148,192,197,82,94,181,40,52,193,143,50,31,90,3,241,205,71,69,33,14,235,76,98,65,169,19,165,71,39,222,160,99,224,151,100,128,147,79,185,184,50,28,14,149,94,159,26,6,206,105,128,213,5,141,89,129,74,245,168,218,45,163,32,210,197,41,206,211,64,23,3,0,42,69,57,21,5,73,25,245,160,7,212,82,24,219,33,177,82,177,194,147,89,210,49,27,141,33,17,
92,71,30,243,180,85,102,64,181,50,190,225,81,206,112,41,142,228,85,27,228,115,78,6,145,185,4,80,55,177,8,59,169,105,128,237,38,156,31,39,20,174,101,113,113,154,90,93,184,162,130,236,48,213,139,37,203,19,80,224,86,133,164,88,135,112,29,104,21,135,130,1,197,58,160,59,183,116,230,167,0,133,230,153,76,90,51,77,165,164,33,174,112,42,19,154,176,71,173,35,70,24,112,41,140,138,35,243,138,187,115,40,125,184,35,129,85,226,182,37,198,115,138,177,115,10,197,183,104,198,104,96,87,171,240,0,34,25,170,176,198,29,249,237,87,10,226,60,10,0,175,51,14,130,163,216,113,154,122,167,60,212,132,100,98,144,138,23,40,30,50,8,230,169,168,150,220,134,25,193,171,87,0,163,245,56,171,16,34,205,111,181,135,20,3,66,193,50,202,128,228,102,150,103,194,251,213,9,224,146,213,247,197,187,20,145,220,25,56,115,205,2,76,148,181,57,14,24,26,97,20,229,226,152,203,173,204,77,244,174,117,254,249,250,215,67,19,238,24,172,59,196,217,112,192,122,214,114,34,68,20,180,148,185,169,76,144,52,228,102,92,133,239,77,235,86,98,64,
171,146,57,166,149,198,135,90,64,90,80,205,156,10,212,0,84,54,137,149,207,173,89,43,138,210,214,46,214,35,52,202,123,83,40,24,84,109,214,164,165,64,15,90,0,130,150,165,120,128,25,21,26,140,154,99,19,56,169,4,180,217,20,1,197,68,122,80,1,114,224,240,42,37,0,12,208,221,105,9,166,49,193,179,78,7,154,136,28,83,193,160,101,132,106,36,56,83,143,74,131,118,57,160,205,193,28,82,38,196,182,173,156,131,86,56,170,118,204,119,213,151,125,163,222,134,33,248,20,17,81,171,18,57,165,221,72,5,219,154,137,144,142,212,173,41,66,49,82,161,14,51,64,202,244,84,146,174,13,20,192,210,168,39,64,91,53,61,33,80,221,104,2,174,40,61,41,236,48,113,72,6,77,0,87,32,131,78,83,154,178,96,12,58,212,77,9,67,199,34,128,25,69,72,177,22,32,102,172,165,170,160,201,228,210,17,85,69,12,163,21,112,196,184,232,42,41,33,192,36,80,5,12,252,216,169,21,138,244,168,207,222,52,234,99,45,175,43,205,11,26,134,220,42,174,227,235,78,89,24,48,25,160,11,180,180,213,57,2,137,14,20,210,17,12,178,146,72,29,42,25,14,87,154,24,241,80,150,
160,8,227,56,98,41,179,158,69,12,112,192,138,108,199,52,198,71,154,92,156,210,81,64,222,197,118,235,75,23,222,205,53,193,7,154,116,125,13,103,125,76,122,146,150,166,238,62,148,244,3,25,165,113,193,173,13,8,193,173,203,33,254,142,185,244,172,30,245,185,108,248,140,125,41,9,50,89,35,92,231,28,211,25,114,49,79,102,205,54,129,145,249,116,248,208,14,180,180,3,205,0,41,64,104,9,138,117,29,233,128,171,247,133,62,240,3,182,152,191,120,83,239,63,134,144,17,219,224,100,213,128,65,90,163,147,86,160,4,39,52,198,53,186,210,19,67,245,166,18,64,52,132,86,152,7,115,82,219,113,199,106,141,65,221,154,149,120,52,198,76,64,96,65,172,251,203,63,249,105,31,4,122,86,136,166,203,247,13,33,88,197,138,98,14,215,171,67,145,76,154,217,100,36,142,13,87,18,52,13,181,185,20,8,208,129,182,154,205,190,25,156,159,90,191,19,6,77,194,168,204,119,72,115,73,171,137,234,84,165,165,97,134,164,53,145,2,138,120,118,245,166,84,214,177,121,179,40,199,25,173,80,35,94,213,118,194,191,76,212,199,154,114,168,11,140,82,26,163,
82,7,166,82,200,227,117,70,90,144,14,38,154,14,13,55,52,160,211,24,242,196,247,167,42,128,51,80,135,230,148,200,73,160,67,164,168,136,169,71,52,214,28,80,50,6,92,158,42,54,56,56,53,161,108,188,19,89,247,28,202,223,90,2,227,115,154,112,235,81,167,90,177,2,7,147,154,46,59,134,220,142,149,26,166,91,154,209,116,0,12,10,129,208,3,197,23,21,193,112,137,144,42,48,75,55,52,75,46,197,198,42,187,74,79,78,40,2,233,96,163,36,212,79,33,39,142,5,85,220,79,4,213,144,1,94,40,11,145,150,39,189,88,182,124,12,26,174,195,20,232,129,46,49,76,162,236,139,184,81,79,29,40,169,32,184,6,78,5,59,203,96,41,99,32,114,106,80,114,40,25,66,84,101,57,52,209,87,39,77,203,80,109,2,129,17,130,71,52,255,0,51,35,222,148,168,197,51,24,166,3,148,225,133,89,221,184,115,80,71,30,238,77,77,140,113,64,194,144,140,140,82,209,154,4,102,205,16,89,176,59,213,196,179,93,163,57,52,241,110,178,62,243,83,156,40,228,226,144,202,173,103,26,169,60,213,111,44,6,173,23,195,169,0,213,55,66,167,154,0,122,176,169,188,176,203,131,85,122,
26,152,92,109,28,211,1,146,219,198,20,156,243,89,140,48,77,91,154,115,207,61,106,163,122,246,160,6,182,49,80,22,230,156,239,158,7,74,142,128,29,70,118,140,210,83,101,56,81,64,219,208,142,71,222,105,99,28,83,49,205,77,192,28,84,37,169,148,119,0,72,161,152,149,164,164,110,149,69,54,34,140,176,21,179,8,33,0,30,149,147,108,187,166,80,125,107,117,84,1,128,40,18,25,181,168,195,10,144,144,41,140,222,148,20,34,156,211,198,59,212,64,226,145,228,61,168,2,198,125,40,168,163,127,151,147,83,35,41,20,198,0,224,230,153,52,165,200,205,61,136,207,20,201,148,46,49,72,68,85,97,119,237,246,170,245,126,32,12,60,250,80,50,177,39,189,53,186,82,177,198,105,132,230,129,9,140,82,100,175,106,114,140,158,106,80,128,142,148,1,1,184,96,58,98,152,211,179,12,26,146,229,66,129,129,138,171,154,99,31,156,213,123,180,221,31,11,205,88,90,113,80,120,60,138,68,178,157,147,156,20,57,168,167,24,144,213,245,133,16,146,162,169,221,174,31,35,165,8,72,174,64,61,170,58,146,152,7,204,51,210,161,162,90,30,177,182,224,118,241,
91,54,202,132,12,40,7,21,78,50,165,70,5,88,134,77,132,213,162,210,177,119,129,214,171,77,56,206,22,155,61,193,97,182,62,73,168,150,41,72,249,129,205,50,132,220,77,29,105,74,48,60,138,153,35,30,94,72,230,128,32,197,68,210,149,108,98,172,237,20,199,129,90,128,33,13,186,142,245,27,131,19,99,52,244,108,140,208,50,194,244,165,42,77,54,19,184,243,83,133,20,8,142,55,49,240,122,85,91,199,141,152,20,252,106,204,163,57,21,66,84,42,220,210,16,202,208,178,79,147,113,21,159,90,48,200,145,196,6,104,2,203,14,42,156,141,131,205,89,89,67,244,170,179,143,156,208,8,175,48,44,65,21,9,171,63,90,129,198,26,152,52,54,158,174,195,129,77,3,39,21,97,34,80,61,105,8,24,18,162,157,110,14,250,82,51,83,195,24,11,158,244,203,185,43,54,213,206,40,164,124,1,138,41,18,94,79,156,100,84,234,64,21,86,41,2,12,83,140,128,242,77,3,37,149,248,192,168,40,44,15,122,7,61,41,128,82,5,201,167,237,56,160,3,154,0,122,29,189,169,217,205,52,46,41,212,0,211,197,52,156,211,155,165,51,109,2,28,178,21,233,81,203,43,55,25,165,34,154,
192,98,144,4,115,50,156,30,149,97,145,100,25,53,75,189,92,129,178,184,160,99,37,132,5,202,138,164,196,243,90,132,100,98,168,92,71,181,253,141,0,83,145,88,158,41,254,78,232,241,208,212,171,78,166,6,76,136,81,138,211,59,212,215,57,243,78,106,33,64,197,168,229,82,70,106,74,49,158,40,96,213,209,92,2,79,74,151,28,85,144,138,5,64,216,220,113,73,16,149,134,226,145,169,105,24,113,154,6,203,26,122,134,156,103,181,107,51,5,21,147,167,130,110,56,29,171,74,92,228,83,18,16,190,105,40,0,158,130,138,6,20,132,82,147,138,105,52,128,64,72,169,81,184,235,81,83,145,79,90,0,153,122,138,124,195,56,166,14,162,157,112,251,113,76,8,9,3,173,93,89,81,97,224,130,113,88,247,18,49,106,183,23,250,177,64,199,177,201,164,160,159,94,213,24,144,49,249,105,8,148,28,83,196,184,21,93,157,177,197,68,236,248,201,160,7,220,76,93,177,218,163,81,220,211,23,147,79,127,153,112,41,140,118,228,29,233,124,197,29,197,87,242,240,42,22,60,208,22,52,21,131,116,53,21,210,167,149,147,76,182,60,98,146,253,73,136,30,194,147,208,151,
161,75,233,74,6,123,84,67,53,52,114,100,133,34,165,59,146,157,217,44,77,183,131,90,144,64,173,30,88,114,107,39,163,86,229,190,124,165,250,85,154,49,171,109,26,29,216,230,154,24,22,34,150,225,249,192,53,20,103,230,164,34,82,160,246,20,143,128,156,83,170,39,110,212,0,202,40,162,128,43,220,196,79,204,42,40,213,128,233,87,88,100,83,49,76,119,27,8,32,243,83,51,96,84,99,131,78,44,10,115,72,68,82,201,130,42,41,128,100,200,167,72,165,135,21,27,49,84,33,133,48,43,51,96,226,172,70,78,222,106,153,60,213,168,159,114,210,68,167,169,106,216,130,248,167,221,40,28,213,116,109,140,13,77,60,170,232,61,105,150,85,207,52,133,3,26,29,182,12,210,22,45,17,43,214,134,198,217,25,194,183,90,150,57,27,240,170,152,36,212,233,144,57,169,78,228,45,75,49,176,102,193,226,172,153,81,7,90,160,15,52,188,145,210,170,197,216,158,105,242,126,83,197,21,94,138,99,177,172,51,75,154,125,33,20,136,27,83,192,56,205,87,205,73,20,161,78,13,0,90,163,2,154,178,43,116,52,250,0,74,41,105,64,205,0,48,140,211,11,1,193,169,58,26,
130,72,201,108,138,0,11,14,230,152,228,118,166,156,142,180,153,160,5,239,83,253,162,56,192,3,169,170,146,190,209,214,171,22,44,192,230,129,154,233,48,38,156,234,178,119,170,113,158,149,36,147,44,107,150,56,164,3,101,64,167,142,149,94,73,85,62,181,55,218,98,101,201,122,207,153,131,177,32,228,83,4,67,59,239,124,211,20,19,210,149,197,75,16,194,102,129,145,17,131,66,140,181,43,28,147,81,44,133,90,128,110,197,178,56,170,167,169,169,154,65,183,138,135,169,160,66,80,126,233,167,133,166,74,70,48,40,7,177,103,75,57,153,190,149,168,203,186,178,244,159,245,205,244,173,113,208,82,38,35,49,181,106,35,210,172,245,170,243,96,30,40,25,19,28,208,6,105,164,226,136,220,103,20,0,245,25,53,40,24,166,168,199,52,236,208,3,129,230,146,232,244,167,196,1,39,52,219,177,210,128,51,231,29,13,89,132,230,32,106,25,23,117,77,26,237,143,6,152,193,185,6,152,137,180,26,121,166,151,20,132,47,214,162,145,179,78,45,154,141,168,1,20,129,214,154,243,129,192,166,200,220,98,160,57,166,50,116,151,174,234,141,185,38,154,
180,162,129,162,68,151,202,4,226,161,184,186,51,0,49,129,67,140,131,85,251,212,76,206,96,57,60,84,177,161,87,25,20,216,70,94,172,116,162,42,225,24,223,81,209,198,210,72,2,140,214,202,143,46,46,123,10,204,181,153,98,108,181,88,146,237,100,24,92,213,154,52,35,54,91,154,114,158,115,81,102,165,67,197,34,73,148,230,163,198,77,42,156,82,208,3,89,112,50,42,29,248,60,213,138,130,88,206,120,160,0,200,40,83,186,161,32,244,53,52,88,219,76,96,69,48,231,53,55,106,76,82,16,66,189,233,46,99,13,25,0,115,79,79,189,67,245,160,25,136,195,12,69,79,109,222,155,114,187,102,60,113,79,183,31,38,104,68,45,201,105,165,169,198,153,176,213,26,141,111,152,96,208,6,6,41,92,21,92,138,141,11,19,220,210,21,245,29,197,61,80,177,2,165,134,217,159,150,24,21,101,99,219,218,128,185,15,146,2,81,179,138,177,183,61,169,174,190,148,133,114,185,139,113,226,138,157,65,197,20,199,114,230,71,173,7,138,98,70,65,230,165,192,198,41,8,129,185,60,82,21,53,56,80,15,74,113,3,20,192,172,24,169,226,166,73,200,24,57,164,120,253,5,
68,120,160,13,4,59,215,34,158,126,85,170,182,210,21,82,41,198,98,199,4,210,24,253,212,19,145,77,205,40,230,152,134,178,6,161,173,142,204,173,89,88,135,122,126,0,169,184,24,115,69,34,159,152,26,132,3,197,116,14,138,195,144,13,84,188,141,22,46,20,10,105,142,229,104,143,201,159,74,207,185,148,188,135,147,90,107,181,109,235,50,104,201,98,64,166,4,57,167,70,223,54,41,132,82,175,222,20,12,150,97,192,165,39,100,34,156,221,42,57,255,0,213,138,4,69,191,138,137,134,105,199,165,52,54,5,38,68,152,168,220,98,156,72,3,222,161,29,105,244,38,9,232,59,121,61,233,141,75,72,212,9,178,246,146,167,204,102,237,90,195,0,85,45,50,61,144,110,35,239,85,169,40,26,216,126,69,85,152,252,245,38,106,9,56,57,160,162,55,52,66,64,110,105,134,149,71,67,76,101,177,75,81,172,131,111,53,11,78,251,142,40,2,218,156,26,91,175,225,170,138,210,59,45,90,185,232,185,244,164,34,189,76,15,203,80,227,38,172,136,177,25,205,0,86,99,76,167,30,180,109,221,242,142,166,128,25,185,125,105,172,235,211,52,255,0,236,199,60,231,245,168,
30,194,116,228,143,214,152,134,190,51,214,152,72,199,90,144,89,190,50,122,253,106,25,98,41,64,238,56,115,210,154,249,2,163,4,138,11,103,173,43,139,155,66,68,57,4,154,174,122,212,222,96,9,138,108,43,185,249,169,150,164,183,113,138,112,106,213,49,145,88,252,184,226,130,164,140,83,138,177,81,186,31,145,234,42,88,228,69,28,145,154,173,229,30,230,158,176,171,119,170,29,219,45,9,163,254,240,252,234,88,92,57,249,106,162,219,40,60,243,83,174,35,31,47,2,144,145,110,142,42,33,38,83,173,9,156,208,81,45,20,83,73,52,8,142,100,199,53,18,157,180,249,73,226,170,205,187,168,233,76,101,208,114,41,106,56,51,176,110,169,59,210,16,163,131,77,145,192,35,38,157,85,175,23,229,200,160,2,104,150,97,219,52,223,43,98,224,116,170,234,228,30,181,110,41,3,175,38,128,176,197,82,79,74,126,194,5,74,0,237,78,199,203,76,10,224,10,80,163,61,42,9,25,149,200,6,155,230,55,115,64,205,72,241,180,83,177,237,89,145,220,58,113,158,42,228,55,33,248,39,154,4,78,120,21,29,5,178,120,52,82,1,40,167,32,203,81,64,22,104,168,137,
38,162,118,96,120,52,1,106,148,84,17,200,113,205,76,24,99,52,0,225,80,72,62,106,155,120,168,88,228,208,2,134,194,241,77,239,70,104,160,100,170,228,176,21,40,224,211,45,212,28,158,245,51,47,52,192,145,79,20,236,212,121,218,57,160,54,122,84,216,67,140,139,187,25,25,168,175,8,242,14,106,140,204,201,54,238,245,49,147,206,76,53,22,25,73,152,244,207,20,210,120,171,194,20,198,49,85,238,97,8,155,150,168,12,231,234,105,19,239,10,15,90,1,249,133,5,19,181,71,63,220,20,236,228,211,103,251,180,137,101,114,112,166,162,169,31,238,84,85,45,153,72,112,167,82,194,129,186,211,164,192,224,83,67,72,101,33,234,41,105,80,124,227,235,76,13,187,102,2,37,7,142,41,236,202,106,186,253,209,75,65,104,121,32,84,18,182,105,204,9,165,88,198,57,160,10,230,156,189,41,205,24,167,1,129,76,99,64,201,169,2,143,74,110,57,226,158,40,1,202,0,97,79,184,57,197,48,113,73,35,22,164,33,139,247,133,89,153,255,0,119,128,106,169,233,79,66,72,230,128,35,239,79,135,253,106,209,179,154,150,1,182,65,138,96,94,29,42,43,159,184,42,
66,192,14,106,173,220,192,38,5,33,149,166,124,112,42,156,231,49,154,152,238,115,154,107,69,149,59,169,133,138,20,153,169,76,103,156,84,29,234,30,134,79,65,105,200,197,122,83,104,166,34,104,179,201,167,22,0,210,110,219,24,53,18,157,206,51,69,236,105,123,22,41,84,226,146,138,179,66,112,227,20,140,219,170,37,167,80,43,18,196,220,226,174,1,197,80,143,134,6,175,131,72,76,90,81,210,152,205,140,83,193,226,144,134,200,155,133,67,228,250,244,171,12,192,84,114,56,219,64,200,119,128,219,106,65,205,85,151,131,145,64,156,211,29,139,130,153,48,220,184,161,27,35,154,9,201,164,73,153,40,216,216,167,66,222,245,45,234,114,13,86,78,13,2,190,165,149,145,179,214,174,33,249,70,106,148,3,115,243,218,174,10,101,141,150,21,126,123,212,105,108,1,57,6,172,6,197,46,115,72,69,118,182,80,164,128,115,81,136,28,116,205,93,164,39,20,1,76,74,241,156,31,214,167,142,112,216,28,80,232,27,168,168,100,143,105,5,69,49,23,65,239,69,49,115,229,228,209,64,19,210,31,122,117,49,143,52,134,37,46,78,41,41,104,0,160,100,211,
145,119,28,85,164,137,87,222,129,21,41,115,79,153,54,182,106,42,96,77,3,97,241,86,243,242,230,169,196,132,140,211,203,28,117,160,99,93,203,26,88,159,107,100,212,116,214,52,8,109,203,111,114,106,32,72,28,26,144,140,138,146,218,37,223,243,242,40,25,44,64,236,25,167,60,62,106,237,53,96,24,212,116,166,27,152,193,197,32,51,231,211,82,56,75,6,57,21,152,23,13,205,108,234,82,131,24,218,199,233,89,57,166,134,40,164,156,124,148,171,235,77,157,190,80,41,9,149,159,165,50,164,61,41,152,197,38,140,164,10,197,122,26,118,115,214,153,78,90,96,152,180,228,251,227,235,77,169,34,82,100,95,173,5,26,202,62,81,75,138,65,192,20,164,19,210,130,131,0,115,77,44,105,225,15,122,82,160,3,235,64,16,210,82,100,230,164,218,49,154,0,101,56,83,105,203,210,128,28,40,145,10,129,158,244,47,222,21,37,207,240,208,4,8,187,156,3,86,222,21,85,226,171,66,113,40,173,18,185,94,105,129,66,148,112,115,83,180,42,41,187,84,118,160,8,203,19,222,154,70,120,53,106,53,140,142,69,67,48,1,206,222,148,1,22,5,65,114,132,227,6,172,212,
83,30,130,129,220,172,23,17,159,165,102,158,166,181,88,124,135,233,89,138,51,38,61,235,57,110,68,134,242,41,115,197,79,50,101,70,5,87,52,157,209,45,88,115,57,97,138,69,56,97,77,167,47,44,41,117,2,215,90,92,113,156,80,191,120,85,233,35,18,66,10,142,149,186,54,40,142,181,48,143,43,154,140,198,192,212,136,204,132,10,24,49,209,167,57,52,255,0,180,170,73,176,254,53,20,151,138,153,0,100,227,173,103,187,23,59,137,230,179,114,51,114,53,204,170,228,17,208,85,128,114,43,38,200,245,21,163,0,36,26,105,220,164,54,83,243,84,121,169,221,1,38,161,100,60,138,161,145,146,27,138,35,132,23,235,68,113,144,73,53,60,99,230,160,46,5,8,164,39,28,154,177,142,42,9,161,220,132,3,72,69,107,161,190,60,131,210,170,70,51,147,86,98,110,76,109,77,116,218,112,59,208,43,9,3,109,144,15,90,187,84,19,135,21,124,116,166,80,98,156,1,164,169,99,0,138,64,70,115,138,78,181,104,71,187,160,163,200,199,97,64,138,184,169,99,93,220,84,134,18,122,1,72,191,187,108,26,96,44,195,17,226,138,148,128,71,52,80,5,97,32,199,52,210,252,
241,77,197,20,128,112,106,127,90,140,117,167,238,24,160,7,47,6,167,12,120,230,170,135,193,230,166,14,164,117,160,9,101,96,201,239,85,141,72,205,242,230,161,71,222,105,129,110,34,54,226,156,201,242,241,80,167,202,42,202,156,173,3,42,48,43,214,154,106,212,137,184,123,213,102,7,210,129,13,164,206,58,83,214,54,99,210,154,232,202,104,1,55,31,90,134,86,34,165,193,244,168,93,25,159,129,64,200,156,146,57,168,177,206,42,103,141,213,114,65,21,16,235,76,96,234,85,120,235,80,62,236,252,213,105,136,53,94,98,50,41,9,145,81,180,26,7,90,94,244,136,23,98,226,128,180,102,150,152,236,52,169,169,99,249,88,31,122,78,180,248,144,187,128,40,41,34,238,236,226,172,46,8,21,18,68,113,205,74,171,180,80,3,168,52,82,26,66,34,104,178,114,41,196,124,184,169,21,67,117,167,24,194,142,77,0,69,21,171,201,200,20,233,96,104,135,53,122,205,70,202,75,208,48,5,43,138,230,106,253,234,154,225,114,128,210,42,0,106,105,16,180,124,85,20,87,180,77,211,15,110,106,221,195,109,0,47,90,130,200,17,41,6,172,52,12,242,100,158,41,
8,72,224,145,148,18,105,36,133,150,175,34,224,1,81,92,14,106,83,212,87,212,207,193,86,166,181,75,40,239,77,80,15,90,178,153,21,70,235,147,82,178,224,210,50,224,102,144,138,178,161,242,219,30,149,155,10,254,243,158,213,176,195,114,145,89,190,88,141,143,173,38,181,21,174,197,168,38,0,48,197,79,80,204,167,131,68,144,230,180,34,197,42,16,172,9,163,7,210,144,130,58,214,70,69,147,42,1,145,214,159,21,251,70,113,128,86,169,243,69,87,51,41,201,154,209,223,192,87,46,188,253,42,173,213,231,154,223,32,192,170,121,162,142,102,28,204,83,147,214,133,82,199,10,51,83,91,219,73,113,146,188,40,234,107,66,43,72,208,3,183,145,66,77,137,43,144,217,216,74,78,226,64,21,175,29,168,84,3,53,2,57,94,5,91,134,77,195,154,180,172,90,86,42,202,155,92,138,0,24,167,220,15,159,34,163,13,84,80,201,19,28,138,72,199,122,145,200,34,162,206,222,40,2,90,58,241,77,86,7,235,75,208,210,17,157,115,251,187,140,138,107,62,243,156,83,175,135,239,51,138,75,116,220,185,52,193,12,7,6,173,196,225,215,138,170,255,0,120,129,83,219,
3,131,76,162,197,77,110,62,110,122,83,35,0,158,106,117,80,189,42,73,47,198,19,3,0,83,246,140,85,72,165,218,70,79,90,183,145,183,57,169,98,34,101,0,213,121,162,221,200,237,86,25,183,28,138,97,170,67,40,185,101,224,230,138,150,229,64,30,244,83,25,79,36,158,41,224,83,16,243,82,210,16,194,166,146,158,78,56,166,158,180,0,211,73,154,83,73,64,22,51,251,170,138,51,181,185,169,7,250,170,132,208,5,200,240,253,234,192,224,86,72,156,197,32,244,173,56,101,18,198,24,83,25,37,38,218,90,112,92,210,17,25,24,21,25,230,172,50,140,84,4,115,64,9,138,142,102,242,208,182,51,82,83,38,64,233,131,76,10,19,92,23,77,184,197,86,171,147,219,4,92,131,85,49,76,171,137,81,48,205,76,6,77,71,34,237,52,48,100,88,57,165,57,167,81,138,86,21,132,0,138,59,211,168,2,129,216,57,169,173,145,203,130,138,79,60,212,89,173,109,41,151,203,97,222,129,150,76,68,160,227,156,84,126,91,122,85,133,124,147,82,1,72,146,167,148,212,210,132,117,171,100,84,83,2,84,96,80,34,21,86,60,138,145,163,102,28,83,163,24,94,106,68,234,104,25,53,
178,20,76,26,75,164,222,56,169,99,233,77,150,163,169,29,74,75,9,7,154,155,28,98,151,189,29,234,203,18,56,194,182,69,76,58,211,20,83,199,90,76,68,195,165,65,113,214,167,94,149,5,199,90,133,185,11,114,156,163,34,150,213,3,63,61,169,196,100,84,150,99,131,90,72,182,37,204,10,19,53,78,65,145,197,104,93,240,152,170,93,105,45,132,138,228,17,212,85,39,129,217,137,10,77,107,203,24,242,115,222,153,10,16,14,123,213,20,102,181,148,138,153,197,64,232,87,134,24,173,231,251,184,172,203,212,227,56,160,119,41,160,25,168,238,16,253,225,210,166,69,61,105,179,255,0,170,165,37,161,45,104,84,237,73,75,218,146,177,50,10,112,92,144,7,90,65,87,116,203,127,58,224,19,209,121,170,72,13,59,75,127,34,204,3,212,245,164,171,146,0,177,17,84,235,68,106,133,80,73,226,172,66,133,121,53,20,44,3,253,106,221,0,50,69,220,181,93,99,37,170,211,54,23,154,96,117,39,2,128,43,48,218,112,106,180,173,180,26,181,58,144,217,170,178,166,225,76,104,108,12,75,100,213,144,217,53,12,107,180,98,164,160,24,219,184,55,196,72,235,84,
173,178,24,140,86,174,114,149,75,96,86,36,14,180,132,85,113,251,204,123,213,216,134,16,85,82,164,203,211,138,185,25,28,83,24,231,15,26,238,3,56,166,197,120,9,218,195,21,104,186,109,228,138,200,156,143,52,227,214,128,52,164,144,100,21,34,172,44,204,99,0,226,177,163,148,231,158,213,104,220,228,128,6,40,11,26,145,184,35,21,32,233,85,45,216,18,13,91,160,8,46,16,16,90,138,124,223,234,205,20,132,101,66,70,121,169,199,74,169,210,165,89,70,57,160,9,27,173,52,240,41,202,234,106,11,137,112,216,20,14,196,153,162,171,199,38,91,147,83,211,6,78,220,71,81,84,143,254,172,84,84,132,69,50,100,113,87,180,239,245,28,250,213,98,50,42,237,160,196,127,141,49,150,41,60,220,28,98,134,233,80,128,73,164,34,86,152,22,219,138,70,251,185,53,9,226,117,250,83,231,56,133,190,148,198,0,231,167,74,66,195,189,65,106,217,143,233,78,38,128,34,185,148,55,202,42,174,5,58,102,204,135,20,130,128,19,104,168,38,251,216,171,21,90,95,190,104,1,160,102,166,9,242,212,43,214,167,29,40,25,11,12,26,41,207,201,166,83,24,181,177,
165,32,16,22,245,53,143,91,90,95,252,122,159,173,38,12,178,135,53,56,233,85,208,241,86,7,221,169,100,17,181,54,158,71,25,166,83,64,53,141,58,46,115,77,122,124,84,12,179,31,74,73,105,209,244,166,203,81,212,142,164,29,233,174,193,20,177,232,6,77,58,171,106,33,190,200,248,171,40,174,186,204,67,57,67,248,84,214,250,180,83,76,16,41,4,215,54,122,213,189,45,11,223,70,7,99,73,145,204,117,235,210,160,184,235,83,169,249,69,65,113,214,162,59,130,220,174,189,234,91,49,203,10,136,116,53,45,151,122,185,108,84,182,36,184,92,224,85,113,8,205,89,159,168,168,197,37,176,45,134,58,110,92,118,166,48,198,5,74,122,84,77,214,168,99,24,113,84,110,121,140,138,188,223,118,168,204,50,134,152,21,98,229,113,81,93,141,169,245,53,36,76,1,193,226,163,190,96,85,64,165,45,129,148,169,41,123,82,86,38,67,148,100,224,86,142,159,32,130,76,30,245,159,27,109,60,212,234,217,57,21,164,75,138,58,25,89,76,68,230,179,94,229,65,32,85,79,58,66,48,88,226,154,77,93,141,44,91,89,203,74,49,210,181,85,198,6,77,115,193,136,228,85,
216,164,44,163,158,104,17,167,33,82,189,106,190,253,156,250,84,33,136,60,210,205,146,135,29,232,2,41,174,247,30,159,173,44,111,189,114,69,82,112,65,230,164,138,93,163,20,236,59,23,40,6,144,28,174,105,98,101,45,214,164,68,167,229,76,122,213,115,214,165,99,150,197,48,138,4,68,72,7,173,40,60,113,85,100,36,49,169,96,36,138,99,38,205,67,44,123,185,21,45,29,168,2,145,5,79,52,245,108,212,172,160,246,168,31,229,52,198,91,134,224,199,218,180,237,174,68,171,232,107,8,54,77,75,27,148,63,41,34,128,53,239,37,217,9,199,83,69,100,92,92,29,185,102,201,250,209,83,116,75,104,82,224,156,82,212,67,150,169,145,25,134,64,38,153,66,103,28,212,79,201,38,165,112,71,4,84,45,214,154,26,4,251,226,173,6,25,197,86,79,190,42,202,196,204,224,227,138,24,154,44,184,62,88,168,3,2,77,73,59,50,160,21,89,15,205,72,73,18,25,128,226,175,89,182,232,243,239,89,50,253,227,90,58,115,126,232,140,244,52,236,59,23,122,210,99,29,41,22,148,210,36,99,70,11,238,239,77,184,31,184,111,165,75,81,220,2,98,96,61,40,25,82,208,254,236,
253,106,67,80,219,169,11,211,189,76,220,12,208,198,202,204,163,113,53,92,183,205,138,176,231,0,154,172,188,189,2,36,29,42,25,71,53,35,182,222,42,187,18,198,128,64,58,212,153,52,145,245,169,8,200,160,100,38,146,156,122,210,83,40,84,66,236,20,119,173,235,56,196,80,109,199,106,197,182,255,0,92,191,90,223,132,101,77,38,75,24,135,131,86,87,165,84,101,32,224,14,245,105,6,20,84,177,3,15,150,163,193,169,169,49,66,96,68,84,145,76,15,229,169,38,172,85,105,16,176,96,41,128,46,160,163,215,242,169,22,233,101,232,107,50,72,217,27,4,81,16,111,48,99,52,172,77,141,108,85,61,81,138,89,190,59,213,197,24,81,154,171,169,194,211,219,21,94,180,13,236,114,228,214,134,141,255,0,31,123,189,5,81,150,54,137,202,176,197,94,209,255,0,215,183,210,165,25,173,205,201,53,5,140,133,57,207,210,158,210,121,128,17,88,247,42,198,99,128,107,74,12,249,75,159,74,187,26,216,146,172,91,0,162,160,2,164,86,32,113,67,212,77,92,146,110,78,106,49,72,204,77,40,31,46,105,108,9,88,67,210,163,35,38,134,98,78,5,45,49,140,97,128,
77,80,148,237,201,237,86,238,110,18,16,1,60,214,117,205,208,145,54,129,250,83,64,84,118,203,19,76,127,156,115,65,230,148,117,166,214,128,209,84,142,113,69,43,253,227,78,142,50,249,246,172,44,98,50,166,136,97,121,166,17,131,138,158,24,157,215,32,85,197,88,168,173,64,114,120,165,101,32,116,171,176,90,149,25,35,154,101,220,101,87,165,89,165,202,117,102,208,49,61,56,170,213,165,108,184,136,80,192,123,140,46,64,168,98,159,47,181,141,88,99,129,89,147,252,178,28,82,17,110,229,23,102,120,170,106,62,97,77,14,205,193,36,138,145,120,57,170,45,22,142,68,124,84,22,196,137,192,53,60,77,185,112,105,99,136,9,55,99,154,68,150,21,126,108,154,123,198,8,56,20,157,41,65,230,144,140,185,226,112,228,145,197,62,1,242,126,53,162,202,174,167,56,170,161,85,37,192,233,154,96,52,130,41,142,112,42,241,69,113,210,160,184,136,44,100,138,6,84,221,80,191,222,169,59,210,109,7,173,49,145,83,195,99,147,218,145,134,13,49,134,86,128,123,17,72,75,54,122,209,82,68,49,156,138,43,62,91,153,168,182,93,22,115,22,251,141,
249,86,149,157,185,137,8,108,213,208,7,165,7,21,87,44,165,113,106,178,244,224,213,51,167,200,79,1,177,90,244,160,226,157,194,246,51,109,236,25,121,96,115,86,214,219,29,106,208,52,134,166,225,185,86,91,64,235,222,162,77,60,14,114,106,245,61,122,81,112,51,31,77,4,245,63,149,88,181,179,16,131,215,154,185,69,23,11,145,136,133,59,202,20,241,75,154,155,146,71,229,15,74,95,41,125,41,217,163,52,0,207,37,7,240,138,175,120,168,176,156,1,154,179,89,186,132,217,144,39,97,77,14,197,9,219,39,2,163,136,124,213,33,0,210,22,8,56,21,101,17,78,126,106,138,149,155,36,210,80,3,144,224,212,133,198,42,26,41,140,83,214,138,40,160,100,144,12,202,160,122,215,73,16,194,15,165,96,88,46,235,149,31,141,116,43,247,69,76,137,98,224,122,81,138,51,138,3,12,84,146,4,83,115,138,126,225,81,177,201,161,0,164,210,98,147,52,224,105,140,107,70,173,201,2,133,68,94,64,2,149,169,180,0,226,192,84,78,196,244,165,52,211,76,69,59,203,53,184,25,198,15,181,37,141,154,219,169,60,238,62,181,114,156,171,69,133,97,133,1,234,5,72,
163,2,144,173,0,224,226,129,143,162,145,142,7,20,12,227,154,6,40,235,82,118,168,232,13,67,1,25,112,105,41,236,114,42,23,56,52,0,201,162,141,254,103,0,145,89,87,104,187,243,24,192,21,170,121,170,87,8,1,166,6,101,36,141,181,112,59,212,210,41,6,170,205,214,134,244,20,158,132,102,167,181,108,49,95,90,128,212,246,201,147,187,210,178,91,153,173,199,72,153,126,7,94,43,106,8,196,113,42,227,181,82,181,140,73,58,130,56,173,131,24,197,106,105,98,17,197,67,114,155,227,34,172,186,98,162,147,238,210,3,41,96,196,152,32,241,87,20,144,48,41,216,166,154,0,66,115,214,169,220,167,205,145,86,234,57,70,69,3,42,133,10,41,202,164,138,28,241,83,69,254,174,168,98,68,219,78,42,220,88,35,53,69,190,246,5,93,140,109,140,10,66,99,217,192,61,70,105,123,85,6,98,211,117,239,87,147,149,162,192,87,146,70,14,70,105,185,205,23,3,13,154,106,158,40,2,204,18,158,134,166,148,6,67,154,164,56,57,167,249,199,105,6,128,42,145,201,166,18,69,90,218,61,41,173,24,35,165,49,149,73,205,37,72,209,145,81,145,138,6,57,80,144,78,40,
171,54,156,169,207,74,40,184,174,111,81,77,13,78,6,160,64,84,81,138,55,115,70,234,0,7,20,81,154,40,0,167,3,73,69,0,58,147,52,153,162,128,28,13,25,166,247,167,14,148,132,25,165,237,73,75,64,17,200,226,53,44,123,10,231,174,165,50,76,205,235,87,245,59,147,159,45,9,199,122,201,98,7,38,169,104,80,187,143,173,38,77,55,122,154,82,203,235,78,232,46,133,20,152,230,150,131,76,98,170,230,144,140,26,84,99,154,70,57,52,0,14,148,224,40,2,158,162,128,39,211,215,253,36,86,230,234,199,176,25,184,21,175,82,201,18,140,210,210,80,32,205,20,82,208,2,81,156,82,154,140,228,208,2,151,201,167,83,2,230,164,160,4,197,53,133,62,155,64,12,193,167,168,197,2,157,76,4,164,197,41,166,22,164,3,232,168,247,26,122,156,138,99,22,147,165,45,33,164,2,19,197,68,199,38,165,166,50,211,16,202,206,185,115,230,19,218,180,241,89,179,0,88,143,122,0,171,35,238,170,179,16,113,138,176,227,13,138,171,32,195,80,197,45,134,26,185,6,4,66,170,26,181,110,114,152,244,168,91,147,29,203,250,114,147,113,159,74,216,53,153,166,129,243,30,
249,173,44,213,179,70,4,102,160,157,62,76,138,158,153,39,221,197,33,20,13,7,165,78,209,131,80,145,131,64,17,84,19,177,206,209,86,13,69,34,141,217,160,104,168,115,158,106,120,156,4,197,67,32,195,83,210,22,35,57,235,84,54,5,192,147,52,246,184,98,184,94,41,5,185,238,106,57,19,107,98,128,30,145,151,231,53,118,16,85,48,106,164,65,247,1,90,10,48,184,164,196,202,215,56,197,66,140,49,83,76,187,178,42,139,101,78,51,64,22,178,13,40,21,77,93,129,235,86,160,112,252,30,180,5,137,0,201,197,78,168,0,166,170,0,115,79,221,72,67,89,20,245,21,74,69,93,231,138,191,158,42,148,170,67,211,26,37,183,194,173,20,168,135,203,4,81,64,26,153,166,156,227,138,104,112,71,90,141,166,195,96,116,164,34,108,176,165,89,51,193,164,4,17,214,154,220,30,13,0,78,41,65,245,168,4,132,83,30,227,230,2,128,45,228,81,185,115,140,213,80,228,247,165,201,206,115,64,22,104,168,124,227,138,105,153,177,64,203,27,128,234,104,18,174,113,154,169,188,158,244,155,176,115,156,82,176,23,193,207,74,163,168,234,9,111,25,84,32,185,253,42,
189,206,170,32,66,137,203,145,215,210,177,37,157,165,108,187,18,125,234,111,169,13,146,137,153,203,51,28,213,119,114,77,25,244,166,154,114,38,247,10,146,53,207,45,197,70,58,138,155,52,162,174,56,146,2,49,138,66,115,72,126,238,69,49,95,60,26,208,190,98,76,209,70,40,160,162,100,3,20,241,76,140,252,180,250,4,89,177,255,0,94,43,88,30,43,34,200,226,113,90,192,210,16,180,81,145,73,154,6,45,25,164,39,29,105,155,183,54,1,197,2,37,164,192,160,31,122,40,0,162,147,112,165,205,0,20,152,165,162,128,16,82,210,22,3,189,55,205,20,0,243,205,52,168,160,56,52,226,50,40,1,128,3,79,30,213,30,214,29,233,64,97,222,129,143,166,72,234,191,120,226,156,9,239,81,207,15,155,142,72,160,66,171,171,116,57,164,98,42,24,208,198,79,57,20,250,96,18,54,16,145,89,142,73,57,53,164,121,24,53,159,58,237,115,72,10,146,125,234,170,255,0,122,172,201,247,170,180,159,123,138,108,83,216,97,171,144,46,35,21,78,175,39,220,21,11,114,98,105,233,205,242,145,87,242,42,149,146,109,143,62,181,100,147,138,179,66,76,138,100,172,160,
117,20,221,199,21,94,93,249,164,34,80,65,233,81,200,7,106,141,93,150,141,219,168,1,152,249,177,67,199,145,145,214,159,183,156,210,208,5,31,37,221,185,28,85,149,80,163,21,38,0,166,26,96,216,96,83,12,96,182,113,205,43,48,90,103,155,207,74,64,88,138,18,126,108,113,78,46,20,237,239,81,45,217,9,181,69,44,80,187,190,231,233,64,197,116,201,200,170,211,236,69,203,213,246,92,125,43,50,240,137,78,213,237,64,21,248,61,42,72,24,172,128,212,106,133,105,192,224,213,33,163,64,49,35,173,25,239,80,219,62,230,218,198,174,60,56,28,82,16,67,134,56,52,146,64,174,212,176,2,24,228,84,167,173,0,49,35,10,187,104,169,20,138,40,2,176,39,20,128,19,210,140,224,83,227,157,80,96,140,210,16,155,136,169,1,56,165,73,81,207,74,29,129,237,138,0,77,234,51,147,85,217,242,104,145,72,53,25,28,211,25,98,55,227,173,74,30,169,131,138,122,61,2,44,22,52,224,106,34,64,25,38,162,150,237,85,8,94,77,0,77,36,169,24,228,213,41,174,203,156,40,192,170,238,229,142,105,185,226,153,72,142,227,156,26,132,2,198,167,108,55,83,64,10,163,
0,138,205,173,76,218,212,140,199,181,115,81,154,179,219,6,171,176,193,165,36,38,172,37,73,25,200,168,233,65,193,169,78,194,76,145,206,6,42,49,214,130,217,52,86,128,217,40,144,83,198,8,200,168,58,211,227,108,113,78,229,70,68,193,240,48,42,80,216,92,154,174,104,205,50,203,246,82,3,48,53,168,27,138,193,140,148,32,138,213,130,108,198,51,64,22,115,73,184,131,77,222,13,20,132,57,152,154,111,74,51,70,69,48,30,141,138,113,124,138,139,122,142,244,158,104,205,0,72,41,193,192,235,81,111,95,90,137,219,38,129,151,11,140,113,76,50,26,172,24,142,105,225,193,160,67,201,205,37,25,168,222,78,194,128,36,220,1,169,22,101,238,106,168,110,41,164,243,72,11,251,215,214,143,49,125,106,144,113,142,105,115,154,0,183,230,47,173,27,195,14,13,84,205,62,60,131,145,64,15,162,131,64,235,64,1,24,172,237,78,65,17,80,57,38,180,164,101,69,220,196,1,92,253,252,162,105,201,7,32,116,161,137,187,8,178,6,201,53,1,228,211,121,20,84,115,16,221,192,245,173,43,120,204,155,61,14,43,55,184,174,150,209,2,194,152,244,20,69,234,
56,147,199,30,196,0,80,122,226,158,24,83,15,222,173,13,4,197,41,80,122,209,75,64,17,180,32,142,42,6,133,148,102,173,226,153,39,11,64,21,198,118,154,133,95,13,205,78,252,41,170,100,243,64,19,150,7,165,49,220,1,77,67,72,200,73,160,68,100,230,149,70,105,24,96,211,144,80,49,64,0,138,209,132,230,49,84,0,201,171,145,157,180,1,51,174,229,34,178,229,183,100,115,156,226,175,52,199,118,113,81,203,38,241,130,40,2,131,198,2,212,56,230,173,79,194,226,171,117,166,52,91,183,135,4,54,107,68,98,169,66,70,193,205,89,71,197,33,18,99,21,25,56,110,106,64,192,212,114,117,160,7,169,95,90,42,37,60,209,64,13,217,85,221,112,221,42,209,32,12,230,152,89,95,34,128,8,128,199,20,242,113,80,174,85,169,229,169,8,83,202,226,162,242,206,105,224,230,157,64,17,236,24,197,49,134,211,197,88,3,38,155,34,96,211,2,172,140,88,98,171,48,193,171,141,25,39,138,137,160,99,64,198,69,108,100,66,219,128,2,162,35,25,169,66,74,185,0,26,97,137,193,251,166,152,202,108,73,52,40,37,177,83,203,110,252,21,83,249,84,98,25,51,157,164,
126,21,139,78,230,78,247,30,78,42,57,121,0,211,194,51,30,148,52,79,211,105,171,122,161,189,136,40,171,2,213,202,230,161,32,131,131,214,165,34,6,210,209,72,104,122,8,122,48,7,154,147,104,28,212,21,42,28,174,41,166,90,31,156,209,64,7,210,138,179,68,76,189,42,213,187,241,138,207,50,16,49,83,65,33,82,9,160,46,105,138,144,56,197,66,142,24,100,30,41,227,27,134,122,80,34,80,114,51,81,200,192,240,41,210,58,227,2,161,38,128,22,140,19,218,159,30,8,230,166,92,99,138,0,133,99,39,175,20,224,148,253,235,77,103,81,64,3,47,28,83,23,131,205,59,204,90,105,60,241,64,3,147,219,165,71,74,91,28,83,51,72,7,81,77,44,7,90,105,144,80,3,154,151,204,192,198,42,28,210,140,211,25,32,147,158,106,100,145,64,170,212,225,210,128,45,9,84,154,100,210,149,56,2,161,21,27,18,78,73,164,34,59,211,36,192,99,249,214,107,41,7,154,213,96,113,154,169,44,68,154,44,38,174,85,242,216,140,128,105,132,16,121,21,160,131,106,226,155,36,66,65,211,154,151,17,114,148,107,75,79,189,96,235,17,25,207,189,103,58,149,98,13,92,210,138,45,
200,223,215,181,66,209,146,180,55,65,165,20,148,225,91,26,139,74,58,82,103,21,34,244,160,6,84,114,115,210,166,34,161,110,180,132,67,34,18,188,85,70,141,129,228,86,133,24,7,168,166,50,130,46,41,248,205,62,65,134,52,145,253,234,0,175,50,149,110,105,35,96,15,53,106,120,247,175,21,76,171,41,228,80,5,180,10,121,20,247,96,163,154,173,110,121,246,162,86,37,141,0,79,144,195,173,69,59,136,80,147,207,165,68,9,20,57,223,193,160,69,86,184,243,27,145,138,41,13,187,7,200,198,41,196,28,244,166,135,17,241,185,86,28,214,130,156,168,172,188,17,205,104,67,34,249,98,134,54,78,191,122,158,227,56,168,86,65,184,84,236,115,72,68,123,72,230,138,157,8,198,40,160,10,178,16,23,4,243,85,198,119,113,79,40,88,243,78,8,5,32,20,82,30,180,51,109,168,153,242,104,17,40,56,169,80,3,85,149,179,83,68,220,227,52,198,88,0,14,148,215,93,195,138,99,205,176,241,138,79,56,176,226,144,132,3,230,197,57,128,20,208,121,169,50,8,160,8,241,70,51,74,216,29,233,133,168,1,28,15,74,141,136,3,156,83,201,205,71,34,238,20,0,206,51,242,
226,151,20,192,164,26,126,105,141,135,225,85,110,97,63,121,69,90,164,205,34,109,115,53,145,151,168,197,48,214,164,138,178,15,152,84,15,108,132,241,197,38,137,229,41,10,50,69,77,37,187,47,64,77,68,65,7,145,89,216,86,176,224,228,119,167,163,102,163,165,94,43,80,76,83,214,165,67,197,68,77,40,109,166,130,147,39,14,195,128,106,88,165,98,195,45,80,2,8,206,105,172,222,149,69,182,107,12,17,214,140,251,214,80,153,194,224,53,62,25,91,204,229,141,73,55,52,243,74,28,131,214,160,141,137,61,106,90,6,41,36,154,74,41,84,102,128,12,210,22,52,253,130,145,148,1,64,198,26,76,102,156,6,106,64,162,152,16,180,121,168,218,50,42,230,5,71,40,226,129,21,208,224,243,83,0,49,76,17,138,146,129,137,129,75,197,20,148,8,56,197,55,103,52,234,122,99,189,3,26,23,182,42,59,136,123,168,171,75,142,212,221,252,243,72,12,226,8,56,52,131,173,104,180,113,191,38,170,188,74,15,202,41,140,163,115,22,126,101,31,90,174,132,163,171,116,193,173,77,167,210,152,241,171,240,203,80,226,67,70,149,164,233,50,13,173,146,5,88,172,219,
56,69,185,44,24,243,235,90,10,224,140,228,85,32,66,154,80,216,170,243,207,177,62,82,9,168,33,185,59,176,228,80,51,72,54,106,34,9,52,216,228,83,209,133,78,57,20,198,66,195,29,105,164,30,213,44,131,165,56,1,138,4,85,43,235,64,80,58,84,146,253,234,143,52,12,90,138,85,24,233,82,211,36,251,180,1,8,0,116,166,72,57,169,48,106,57,7,52,0,194,41,41,104,35,52,0,218,67,140,211,177,77,61,104,1,172,50,42,88,198,23,20,204,83,211,165,0,201,20,225,129,171,64,228,102,170,162,228,243,83,43,1,222,129,18,103,28,209,81,51,231,165,20,0,184,166,183,20,224,115,85,230,99,184,138,67,28,251,72,168,15,6,148,154,134,115,128,13,48,36,207,189,61,93,151,161,170,177,202,114,1,171,155,6,220,208,2,46,89,185,230,166,30,213,91,36,119,167,163,28,242,104,2,122,66,105,36,113,26,22,61,170,160,190,4,156,173,34,110,90,38,154,199,2,170,45,241,47,130,188,84,174,251,186,80,152,211,30,36,230,159,154,166,239,131,129,214,172,70,73,65,154,99,28,216,197,71,207,106,29,179,210,150,38,193,230,128,36,88,242,51,77,42,69,88,4,80,113,
64,138,225,120,230,144,138,148,156,209,142,40,25,23,53,12,241,6,92,129,205,88,99,154,101,2,106,230,118,210,14,49,67,2,167,145,138,210,8,9,206,6,104,120,149,199,32,82,177,28,166,96,205,41,4,213,135,140,70,216,166,250,138,44,62,82,16,196,113,78,226,144,167,205,79,88,241,201,52,9,38,54,149,71,52,242,1,164,198,5,50,236,75,20,165,15,181,90,23,43,234,42,133,61,64,233,64,236,92,251,84,123,176,72,169,225,145,24,240,195,243,172,151,136,117,205,52,43,47,42,198,161,182,78,168,222,197,70,226,178,224,184,149,31,150,36,123,213,225,54,241,147,84,129,19,33,2,164,168,147,4,102,165,160,97,77,113,197,58,128,50,104,2,33,156,211,25,136,171,76,2,174,113,85,91,147,76,1,91,52,250,143,24,52,224,104,24,234,118,211,140,226,147,25,25,171,17,99,104,20,132,50,53,32,115,65,81,83,17,197,71,140,83,2,23,92,116,168,192,169,165,25,168,241,64,197,3,34,163,145,0,228,84,192,98,163,144,246,164,33,155,201,24,165,82,122,100,211,115,64,246,160,7,58,224,84,46,157,197,76,217,199,52,170,1,24,166,5,64,236,167,32,226,174,65,
124,195,1,234,41,97,238,42,169,235,76,163,88,222,35,96,100,85,136,216,16,43,8,19,86,226,188,40,160,99,165,33,88,213,42,15,106,134,88,192,25,21,87,251,68,255,0,116,84,241,78,102,66,72,197,0,51,154,15,53,35,1,138,172,242,0,104,1,248,164,42,13,40,32,140,209,72,69,89,142,27,2,136,219,45,75,42,229,141,17,174,57,160,7,72,62,90,128,138,157,206,69,69,76,96,189,106,84,92,154,141,69,72,141,180,210,16,249,62,84,56,170,193,243,222,172,203,243,70,113,89,236,10,181,52,52,91,136,243,129,69,37,153,4,229,143,74,40,2,85,108,84,51,112,73,53,45,85,185,126,112,40,1,134,95,65,81,187,23,20,218,90,99,25,140,26,150,57,24,176,25,226,162,60,212,144,149,80,88,245,20,137,39,44,1,25,234,105,141,58,39,174,106,156,142,89,201,52,194,106,28,137,114,39,150,229,228,227,63,47,165,67,154,74,51,83,204,64,119,169,97,151,105,231,165,67,69,43,216,105,216,180,91,119,34,167,70,59,71,53,74,55,218,121,171,121,10,160,250,214,169,220,210,46,227,168,28,26,78,162,156,131,36,102,153,68,130,70,224,84,155,179,74,35,95,74,93,180,
8,110,106,25,157,148,241,86,10,211,90,48,221,104,17,8,108,138,9,230,158,98,166,109,230,129,143,83,197,1,129,52,198,56,24,6,162,102,192,206,104,2,195,198,178,125,106,47,179,123,212,41,51,41,235,87,11,129,24,98,71,52,132,83,101,193,164,197,61,249,57,168,218,153,90,10,49,75,76,201,20,110,160,46,59,20,148,160,228,102,144,208,2,231,181,5,72,25,167,199,25,36,19,83,20,4,114,40,17,77,152,129,66,74,115,205,88,104,51,156,84,66,212,242,73,164,75,185,34,204,192,112,198,166,138,237,135,222,228,85,34,10,28,81,184,227,20,199,115,67,251,65,58,109,53,102,9,150,81,145,154,200,16,183,21,114,209,188,150,245,6,128,53,118,101,9,61,42,147,117,169,158,224,184,10,6,5,53,35,207,38,144,17,237,226,147,21,49,92,82,21,20,0,213,110,212,240,77,51,103,52,254,148,1,39,154,64,233,72,178,238,237,81,22,6,163,36,131,145,197,48,45,245,165,9,154,173,20,199,56,106,178,37,0,80,49,36,80,56,168,202,102,166,24,144,82,236,0,82,17,85,163,7,165,34,199,130,42,114,148,195,76,7,96,17,210,154,80,1,145,74,189,104,102,226,128,34,
110,134,168,176,195,26,191,80,201,16,99,64,209,86,140,154,176,34,92,84,44,184,38,129,141,171,22,243,249,99,4,113,85,232,20,1,121,238,119,46,20,98,171,245,60,211,80,211,133,2,36,82,216,224,211,129,111,90,72,219,181,62,144,134,55,94,105,41,91,173,69,35,99,138,0,113,108,84,37,185,165,140,23,60,154,89,87,105,226,152,199,35,231,138,148,45,86,143,239,85,176,120,161,137,136,65,198,51,80,203,30,69,88,166,48,205,43,129,75,230,83,193,162,172,148,30,212,83,185,87,30,95,104,200,170,210,46,243,154,140,78,221,13,47,155,234,41,9,12,100,43,214,152,237,180,12,84,142,251,135,21,4,156,129,76,82,122,8,95,138,64,79,64,105,41,240,128,91,154,70,119,185,19,117,164,167,73,247,141,54,178,123,136,41,104,0,158,148,82,0,162,138,41,128,84,229,247,32,246,168,64,205,60,112,49,85,18,145,101,36,28,15,90,179,229,99,4,85,72,145,91,158,226,173,164,164,96,30,149,101,162,117,28,10,92,82,6,167,103,52,0,210,41,164,212,135,165,50,128,35,44,106,41,24,40,235,83,56,170,87,13,150,198,104,1,76,131,174,106,38,98,212,218,90,
0,74,116,142,236,160,103,129,77,165,98,2,243,73,137,145,249,175,211,52,158,99,122,211,123,210,86,119,34,228,139,38,58,243,74,27,53,21,47,106,106,65,114,204,125,13,35,182,15,20,196,148,4,198,57,166,3,147,87,204,95,49,126,41,20,175,80,42,64,192,158,181,158,24,142,245,102,0,91,7,52,193,50,201,2,163,103,11,197,77,142,42,7,137,137,226,153,67,74,164,157,177,77,242,80,28,230,147,230,74,6,231,52,88,44,73,78,83,131,80,200,205,30,61,42,88,207,152,50,162,128,44,69,34,231,230,169,77,218,168,233,84,200,32,210,30,69,0,88,75,191,48,156,140,84,187,235,60,33,86,200,53,118,33,184,1,222,129,18,13,199,160,169,68,69,135,60,82,252,177,47,76,154,65,62,123,82,2,7,27,91,25,166,26,115,29,199,52,148,12,21,121,205,73,147,76,20,236,208,34,68,114,189,42,96,219,134,106,174,106,88,207,20,1,45,70,195,154,121,56,166,19,147,64,9,138,10,143,90,100,178,172,67,154,171,37,224,35,10,49,76,44,90,109,170,185,205,64,242,122,85,95,182,130,112,217,2,148,92,70,87,57,165,116,23,68,226,78,13,68,121,53,15,218,144,158,132,80,
247,72,23,229,228,209,116,43,146,156,82,168,6,168,137,216,190,73,171,113,204,140,120,52,41,92,105,146,129,138,90,50,15,67,154,41,140,145,6,57,167,230,154,189,41,212,132,49,206,6,106,187,146,198,172,63,74,98,160,38,152,194,4,35,173,19,33,39,138,153,120,160,208,43,149,210,61,167,158,181,40,56,161,134,13,37,32,28,26,162,186,152,68,156,17,184,211,234,11,168,76,171,144,121,164,196,202,139,113,43,54,55,19,69,70,141,229,185,200,228,81,82,152,147,44,36,68,161,106,105,52,224,196,38,61,105,149,161,97,72,69,45,37,33,49,12,121,228,82,160,216,9,52,162,146,83,132,197,15,97,52,145,1,228,230,138,78,180,226,164,16,43,35,50,120,20,4,36,212,33,119,49,171,24,219,23,225,81,39,4,230,170,197,52,68,120,52,0,79,65,82,20,25,206,106,104,211,229,224,81,202,9,16,162,54,58,83,204,77,140,226,159,141,189,106,101,96,106,210,177,124,164,112,130,51,145,83,40,230,146,156,156,28,154,99,39,7,3,154,149,6,70,106,177,57,53,60,78,2,243,72,9,10,241,81,84,192,228,113,81,145,205,2,33,158,64,136,125,107,56,229,142,106,245,
204,76,228,17,80,237,219,197,0,86,165,165,117,32,243,77,160,2,163,115,205,75,138,107,166,87,53,50,37,144,210,209,73,80,64,82,210,82,209,96,10,81,195,83,105,69,8,9,9,226,172,91,191,203,129,85,200,194,210,196,219,78,107,82,150,134,130,73,235,86,35,43,142,181,156,37,7,175,21,42,190,8,52,203,69,183,133,94,144,64,21,78,41,241,184,101,226,157,72,101,87,140,63,13,86,109,225,88,212,109,230,144,199,187,165,73,26,149,28,208,33,146,194,27,36,85,51,193,197,105,26,174,208,130,217,166,5,74,154,25,54,184,170,215,155,144,133,80,106,186,204,202,71,122,5,115,126,69,14,1,205,52,40,197,50,9,67,66,9,24,226,156,100,7,165,33,145,184,193,226,163,36,14,166,158,78,106,41,80,145,197,3,30,24,98,154,100,230,161,92,131,131,82,44,100,158,134,152,88,67,116,136,216,110,181,98,25,210,64,54,181,70,246,104,252,147,207,210,171,189,148,145,29,209,156,210,36,209,205,35,182,197,38,163,128,184,143,247,131,4,84,23,23,74,84,168,230,152,209,94,226,127,52,241,80,129,147,205,30,230,163,146,81,208,80,221,134,221,136,228,251,
199,20,218,51,70,43,22,98,20,80,1,61,5,41,82,189,69,32,16,210,138,67,69,52,4,201,59,32,192,197,89,138,228,55,7,131,84,105,234,8,230,180,67,76,213,70,207,189,60,144,5,80,182,144,249,152,61,234,227,30,41,154,1,124,138,104,52,148,83,24,240,212,25,112,105,180,17,64,11,230,102,158,160,17,156,213,115,214,148,19,64,18,177,25,192,53,28,211,8,147,61,79,97,78,68,36,213,91,200,31,239,245,30,148,153,44,166,231,115,19,235,69,39,122,43,36,140,203,71,160,166,208,196,211,119,102,182,53,184,180,82,129,77,103,0,210,184,92,146,53,36,212,119,56,4,0,105,68,225,83,0,115,80,49,36,228,212,73,146,216,168,50,115,78,126,185,162,62,134,156,70,104,75,65,37,160,161,137,81,65,162,138,178,133,8,216,207,106,183,24,249,69,49,70,20,10,149,13,5,12,153,126,90,128,28,85,137,143,201,85,169,130,37,67,145,83,47,74,133,51,138,149,78,5,0,41,52,241,210,162,7,154,147,32,117,52,1,52,111,129,138,118,236,247,170,102,127,155,106,154,80,229,78,73,52,132,90,38,169,205,195,245,162,89,247,12,12,212,12,73,166,49,228,228,98,161,35,
6,157,147,154,126,55,10,4,200,89,128,94,188,212,89,52,233,35,101,228,211,107,51,54,33,162,159,28,101,205,52,240,113,74,194,18,138,13,20,0,149,36,107,147,244,168,234,72,219,28,82,91,141,10,224,154,104,224,212,181,24,3,60,214,163,107,81,221,170,100,108,174,42,3,79,143,189,8,164,89,138,111,44,243,87,99,112,224,96,214,103,90,146,41,54,48,57,226,168,163,81,58,212,149,20,71,114,130,59,212,153,29,234,68,35,116,164,3,34,158,72,168,222,85,85,198,71,52,1,28,129,73,193,193,168,140,49,158,54,140,210,188,200,163,174,105,96,112,244,5,137,2,224,113,73,82,246,166,48,160,6,209,69,62,48,11,115,64,13,68,7,168,21,38,42,79,151,28,1,76,102,197,0,20,214,112,41,165,242,41,180,1,13,204,135,111,25,170,68,30,226,180,136,6,169,220,145,187,2,153,72,173,39,250,186,175,86,143,35,20,221,163,208,126,85,50,141,201,148,110,86,165,169,246,3,218,154,209,128,42,121,72,113,21,88,5,2,149,134,225,81,119,169,71,61,42,172,53,169,1,24,52,149,51,198,113,154,134,179,104,150,172,40,169,65,21,13,57,78,13,82,144,34,84,125,142,
13,94,89,4,138,8,172,231,28,230,174,90,156,197,143,74,164,82,100,212,162,144,82,213,22,6,147,52,224,50,41,173,193,160,4,193,53,50,140,10,98,138,125,0,59,34,171,94,190,16,47,173,79,85,175,62,224,164,38,82,56,235,69,20,82,32,113,98,105,185,199,52,119,169,12,13,142,134,155,25,19,72,79,74,97,169,237,161,45,54,25,120,21,102,230,220,50,141,139,143,165,103,102,201,220,207,165,85,44,125,170,97,1,15,134,7,20,226,0,56,29,40,81,26,136,192,59,84,128,118,166,226,158,156,176,173,81,162,67,188,172,174,113,77,141,57,38,166,145,246,174,59,212,81,19,205,33,18,226,149,122,211,151,238,212,91,136,52,198,44,167,140,84,104,5,56,13,230,166,72,148,122,211,1,160,118,167,50,224,83,246,12,208,203,149,164,34,28,224,212,83,49,45,214,166,84,203,115,81,92,128,24,98,128,34,67,135,21,97,198,86,170,211,252,214,10,121,164,2,226,146,154,146,112,73,60,210,135,94,230,139,161,243,8,196,47,90,105,148,246,166,59,110,106,76,84,223,83,55,33,239,33,97,131,78,72,242,50,105,138,189,42,199,94,149,105,14,42,251,138,128,1,129,
86,226,183,140,14,80,100,250,211,109,209,113,156,115,67,92,50,57,92,113,67,69,180,65,123,109,243,3,26,31,124,85,38,5,78,8,230,180,141,211,159,74,167,62,93,178,5,67,68,56,144,80,58,211,138,48,25,193,166,212,16,78,58,83,72,165,95,186,40,173,81,160,211,210,150,38,193,193,162,155,223,52,19,177,49,233,80,100,250,213,140,110,143,142,181,3,41,83,200,161,142,70,197,148,153,140,2,123,84,115,72,124,195,130,106,8,92,236,24,56,226,154,238,115,77,22,145,47,154,221,216,212,50,57,99,214,152,88,154,74,99,29,130,106,104,24,163,142,106,29,248,161,31,46,40,17,170,100,85,77,196,244,170,143,124,59,127,42,82,60,200,136,235,84,124,135,221,141,166,145,44,212,183,113,34,228,241,86,0,29,170,130,228,40,237,82,44,140,59,210,25,114,152,227,138,85,108,138,27,165,0,69,73,70,105,14,64,160,5,170,243,67,156,145,78,73,75,62,14,42,59,217,218,48,21,123,245,163,97,236,86,35,6,146,153,230,231,173,40,96,212,41,38,10,87,22,151,4,131,64,168,217,207,76,241,77,137,187,12,61,106,104,241,182,160,167,198,216,52,140,211,212,
89,137,7,25,168,106,105,136,36,98,162,61,107,38,15,113,40,162,138,66,31,191,140,85,171,38,201,34,169,85,171,5,221,55,94,149,73,141,23,136,244,160,12,212,216,20,220,1,90,26,8,163,2,161,115,134,230,167,168,46,7,122,104,104,122,28,138,125,82,14,87,161,171,49,62,229,160,25,37,50,81,148,57,167,211,100,5,151,2,144,138,44,128,158,40,171,9,7,63,54,104,166,61,10,96,101,255,0,26,186,135,129,85,98,232,106,212,99,129,64,145,34,128,57,20,19,197,40,166,57,237,72,8,156,240,106,191,83,86,24,103,138,64,128,83,24,208,191,46,41,35,251,245,33,59,106,29,216,108,138,6,73,56,24,207,122,72,135,25,166,51,22,28,210,196,216,56,164,34,125,216,90,128,156,181,72,255,0,118,162,29,105,140,124,114,4,108,26,182,15,3,21,151,51,124,252,85,203,71,46,156,246,169,185,23,212,179,77,118,194,154,81,205,54,85,249,9,170,25,3,202,192,113,197,87,98,88,228,212,157,106,54,235,67,27,28,169,184,103,52,52,100,10,146,30,70,42,66,41,8,207,35,6,146,173,200,138,195,166,42,171,46,27,21,155,77,16,226,208,168,188,231,181,61,199,76,82,
129,133,2,148,115,84,144,210,208,64,56,167,7,8,57,164,60,82,21,13,222,157,199,177,102,222,225,3,18,127,157,71,36,202,239,144,42,161,224,212,209,39,114,105,38,196,164,73,154,114,114,224,83,79,90,84,59,91,62,149,102,132,215,172,18,32,128,114,107,58,164,154,86,145,201,99,76,81,243,10,201,238,98,247,37,29,5,75,18,6,7,53,29,73,19,96,26,209,26,33,172,163,38,152,195,2,158,199,36,211,27,165,48,104,34,98,28,85,135,140,63,90,170,167,12,42,224,233,72,75,81,170,2,140,14,212,198,235,82,55,74,139,189,81,97,138,59,82,209,158,40,2,34,105,80,110,96,41,15,38,130,74,212,144,205,40,246,162,245,233,239,74,142,174,78,43,43,113,245,167,71,43,70,114,40,21,205,90,107,46,69,71,4,222,96,231,173,77,154,10,26,9,29,205,46,226,123,210,53,68,238,23,189,0,60,182,57,205,74,140,24,96,213,96,119,119,167,33,33,168,1,37,79,45,178,42,11,182,223,24,39,181,95,56,97,205,87,189,64,45,201,0,80,246,6,244,51,49,197,42,28,53,54,146,177,50,69,162,56,205,64,195,154,3,176,239,67,57,106,211,152,166,238,52,154,40,162,161,178,64,
117,160,245,162,146,144,5,20,81,64,5,89,176,63,233,2,171,85,205,58,34,211,110,236,41,173,198,141,58,110,57,169,54,26,4,102,181,52,35,34,162,148,102,172,16,71,21,28,139,154,0,166,233,131,197,75,2,99,173,60,39,57,53,32,20,199,112,21,98,37,27,122,85,122,154,6,231,20,132,50,101,195,102,138,178,192,48,162,128,48,161,27,79,61,42,113,39,56,197,67,244,164,45,183,154,161,236,90,243,0,90,173,37,192,35,11,81,73,41,101,192,24,168,115,89,182,67,145,48,145,129,235,78,51,49,168,199,34,157,176,211,76,19,31,146,71,90,59,208,6,6,40,29,106,141,17,56,81,142,149,12,131,14,49,82,7,226,163,144,229,168,16,165,137,20,128,227,154,78,212,10,0,174,231,115,19,86,108,164,218,229,125,106,179,140,49,164,4,131,144,113,88,223,83,46,166,207,189,54,94,99,53,94,210,125,234,85,143,53,36,178,124,164,10,213,106,104,181,43,158,42,51,82,99,214,160,57,221,138,108,36,203,16,158,181,47,90,143,114,34,245,167,23,80,155,187,82,184,93,12,110,26,154,118,129,146,41,60,213,99,140,83,38,97,192,6,147,104,27,86,17,228,221,192,24,
168,247,17,222,146,138,205,182,100,219,20,177,61,105,50,69,20,82,184,9,79,14,192,112,105,148,180,238,3,214,82,15,52,175,46,126,239,21,29,37,28,204,119,98,154,1,193,6,131,73,72,68,224,228,102,157,76,139,238,211,241,91,38,106,152,117,168,217,241,192,167,187,237,24,239,80,103,53,50,145,50,97,239,83,219,185,206,42,12,211,162,59,95,53,41,234,74,101,220,250,211,36,0,0,105,4,128,245,168,230,108,168,197,104,217,165,201,1,7,161,166,150,2,171,130,71,122,80,222,180,41,19,206,57,223,158,56,164,45,154,107,28,154,3,98,162,250,147,113,216,164,220,41,11,26,109,14,64,63,204,43,247,73,20,190,107,255,0,120,212,117,34,68,239,247,65,169,187,97,169,60,55,76,56,60,211,101,98,205,154,104,137,144,229,169,72,205,104,174,90,76,18,66,134,158,103,108,83,54,211,128,207,106,99,177,61,164,142,210,99,168,171,55,81,151,139,111,173,54,208,5,237,138,146,102,201,160,86,50,36,129,163,52,194,132,117,173,94,15,81,65,64,221,84,84,242,139,148,201,193,162,181,76,40,71,221,21,70,91,87,86,224,103,62,149,46,54,37,162,10,
74,115,35,41,249,129,20,218,145,5,45,0,18,112,41,225,8,237,77,43,141,33,21,11,84,170,138,189,179,66,46,218,120,25,53,162,137,106,34,170,43,28,96,86,181,186,34,70,54,140,85,24,208,1,86,18,82,163,20,236,135,100,91,167,32,239,80,194,205,39,106,176,6,40,0,42,164,115,218,171,76,202,120,81,83,200,126,92,10,172,70,58,208,3,59,210,129,197,4,100,211,133,0,52,138,64,112,120,167,19,138,110,225,64,22,99,125,203,69,66,146,132,162,128,50,251,112,106,9,27,45,69,20,216,164,244,24,41,15,90,40,172,228,102,40,98,13,72,38,245,20,81,74,227,76,111,152,73,228,212,138,212,81,85,22,84,91,31,144,105,173,214,138,42,203,20,30,41,71,90,40,160,101,121,126,249,166,81,69,98,204,25,61,177,195,145,234,42,193,162,138,210,27,26,195,98,54,227,173,71,56,219,130,40,162,156,158,130,145,17,98,122,156,213,152,71,155,17,6,138,43,52,66,32,145,76,111,140,211,9,61,232,162,165,136,74,40,162,128,10,40,162,128,10,40,162,128,10,40,162,128,10,40,162,128,28,172,87,165,47,152,222,180,81,78,225,113,9,45,212,211,104,162,144,5,57,
58,209,69,53,184,15,160,242,40,162,181,40,66,152,25,166,209,69,22,37,137,79,68,7,173,20,84,216,104,127,148,15,76,230,159,29,140,175,201,92,10,40,163,149,20,209,39,216,212,117,39,53,58,70,168,184,20,81,78,195,176,217,35,12,61,234,179,41,83,131,69,20,202,18,156,159,120,81,69,48,46,33,32,241,82,21,110,244,81,64,7,148,113,205,0,81,69,33,6,40,192,61,104,162,129,17,201,109,28,157,122,213,118,178,65,252,120,162,138,86,65,100,57,33,134,49,159,188,106,55,92,183,202,56,162,138,171,36,85,146,27,176,250,83,213,72,237,69,20,12,177,24,37,122,84,168,153,113,158,5,20,80,34,234,133,65,242,209,147,69,20,8,42,22,198,104,162,144,13,110,7,2,163,222,65,228,81,69,0,43,48,34,153,69,20,192,67,69,20,80,51,255,217);


procedure pub__init(var x:tpubinfo;const xbuildFolder:string);
var
   p                            :longint32;

begin

with x do
begin

count                           :=0;
count_text                      :=0;
count_image                     :=0;
firstImage                      :=false;
buildFolder                     :=xbuildFolder;

title                           :='';
fname                           :='';
lname                           :='';
year                            :=1900;
month                           :=1;
day                             :=1;
rights                          :='';
subject                         :='';
des                             :='';
publisher                       :='';
isbn                            :='';
uuid                            :='';
docHeading                      :='';
firstError                      :='';
firstChapterIndex               :=-1;//not set

slot_contentsHtml               :=0;
slot_contentsOpf                :=0;
slot_titlepageXhtml             :=0;
slot_tocNcx                     :=0;
slot_stylesheetcss              :=0;

//built options
headersize                      :=pub_headerSize_def;
headerAlign                     :=pub_headerAlign_def;
headerVPad                      :=pub_headerVPad_def;

textsize                        :=pub_textSize_def;
textJustify                     :=pub_textJustify_def;
textVPad                        :=pub_textVPad_def;
lineHeight                      :=pub_lineHeight_def;

indentChars                     :=pub_indentChars_def;
blankLine                       :=pub_blankLine_def;

dropcaps                        :=pub_dropCaps_def;

formatUp                        :=pub_formatUp_def;
sceneSep                        :=pub_sceneSep_def;
quotesSingle                    :=pub_quotesSingle_def;
quotesDouble                    :=pub_quotesDouble_def;

imageConversion                 :=pub_imageConversion_def;
coverWidth                      :=pub_coverWidth_def;
coverHeight                     :=pub_coverHeight_def;
buildNumber                     :=pub_buildNumber_def;//20oct2026

pub__makeStrs( x ,true );

//clear
for p:=0 to pred(pub_filelimit) do
begin

style[p]                        :=pub_none;//not in use
w[p]                            :=0;
h[p]                            :=0;
nref[p]                         :=0;
nval[p]                         :=0;
name[p]                         :='';
next[p]                         :='';
data[p]                         :='';
dataLen[p]                      :=0;
refdata[p]                      :='';
refdataLen[p]                   :=0;
format[p]                       :='';
headingRaw[p]                   :='';

end;//p

s                               :=faststr__new8;
s.floatSize                     :=100*1000;//100K
t                               :=ttextcore.createdataonly;
tlen                            :=0;
docText                         :=faststr__new8;

end;//x

end;

procedure pub__free(var x:tpubinfo);
begin

with x do
begin

faststr__free(@s);
freeobj(@t);
faststr__free(@docText);

end;//with

end;

function pub__documentFileList(const xbuildFolder,xbuildFileData:string;const xfindWordCount:boolean;var dwordcount:longint32):string;
var
   a                            :tdynamicnamelist;
   d                            :tstr8;
   w                            :ttextcore;
   l                            :tdynamicstring;
   xlen                         :longint32;
   xpos                         :longint32;
   xline                        :string;
   xwithin                      :boolean;
   xok                          :boolean;
   p                            :longint32;
   df                           :string;
   xappFolder                   :string;
   dformatDocument              :boolean;
   dchapterOne                  :boolean;
   xdocType                     :longint32;

   function xcleanLine(const xline:string):string;
   label
      redo;

   var

      bol1            :boolean;
   begin

   //strip leading and trailing whitespace
   result             :=stripwhitespace_lt( xline );
   bol1               :=false;

   redo:

   //strip leading '"'
   if (strcopy1(result,1,1)='"') then
      begin

      bol1            :=true;
      strdel1(result,1,1);

      goto redo;

      end;

   //strip trailing '"'
   if (strcopy1(result,low__len32(result),1)='"') then
      begin

      bol1            :=true;
      strdel1(result,low__len32(result),1);

      goto redo;

      end;

   //finalise
   if bol1 then result:=stripwhitespace_lt( result );

   end;

   function xcanadd(const xfilename:string):boolean;
   begin

   result                       :=pub__fileFormatSupported2( xfilename ,xdocType ) and a.addonce(xfilename);

   end;

   procedure xaddWordCount(const xfilename:string);
   var
      b                         :tstr8;
      e                         :string;

      procedure xincWordCount;
      var
         p                      :longint32;
         bol                    :boolean;
         lastbol                :boolean;

      begin

      //init
      lastbol                   :=false;

      //get
      for p:=0 to w.len32 do
      begin

      bol                       :=w.docsep(p);

      if (bol<>lastbol) then
         begin

         lastbol             :=bol;

         if not lastbol then inc(dwordCount);

         end;

      end;//p

      end;

   begin

   //defaults
   b                            :=nil;

   //check
   if not xfindWordCount then exit;

   try

   //init
   b                            :=faststr__new8;

   //get
   if io__fromfile( xfilename ,@b ,e ) then
      begin

      if (w=nil) then w:=ttextcore.createDataonly;

      w.iosetdata(b);

      //word count
      xincWordCount;

      end;

   except;end;

   //free
   faststr__free(@b);

   end;

   function fok(const xname:string):boolean;
   begin

   result             :=io__fileexists( xbuildFolder + xname );

   end;

   function fmarker(const x:boolean):string;
   begin

   case x of
   true:result:=pub_fileMarkerOK;
   else result:=pub_fileMarkerNotFound;
   end;//case

   end;

   function faddOK(const xname:string):boolean;
   begin

   result             :=fok(xname);

   if result then d.sadd( fmarker(result) + #32 + xname + #10 );

   end;

begin

//defaults
result                          :='';
d                               :=nil;
a                               :=nil;
l                               :=nil;
w                               :=nil;
dwordcount                      :=0;

//check
if (xbuildfolder='') then exit;

try

//init
xlen                            :=low__len32( xbuildFileData );
xpos                            :=0;
d                               :=faststr__new8;
a                               :=tdynamicnamelist.create;
xwithin                         :=false;
xappFolder                      :=app__folder;
dformatDocument                 :=true;
dchapterOne                     :=false;

//get
while low__nextline1( xbuildFileData ,xline ,xlen ,xpos ) do
begin

if (xline<>'') then
   begin

   xline                        :=xcleanLine( xline );

   if xwithin then
      begin

      //remove leading "file:" and trailing "msg"
      xline                     :=pub__extractDocumentFile(xline,dformatDocument,dchapterOne);

      //line is a full filename "c:\folder\abc.txt" or "?:\folder\abc.txt" - 17oct2026
      if (strcopy1(xline,2,1)=':') then
         begin

         //1. folder              = buildFolder   -> name only
         if strmatch( io__extractfilepath(xline) ,xbuildFolder ) then
            begin

            df                  :=xline;
            xline               :=io__extractfilename( xline );

            end

         //2. folder              = same drive as app -> portable folder + name
         else if strmatch( strcopy1(xline,1,1) ,strcopy1(xbuildFolder,1,1) ) then
            begin

            df                  :=xline;
            xline               :=io__makeportablefilename( xline );

            end

         //3. portable Folder    = leave as is / convert to name only / change to global drive letter
         else if (strcopy1(xline,1,1)='?') then
            begin

            df                  :=io__readportablefilename( xline );

            if strmatch( io__extractfilepath(df) ,xbuildFolder ) then
               begin

               xline            :=io__extractfilename( df );

               end

            else if not strmatch( strcopy1(df,1,1), strcopy1(xbuildFolder,1,1) ) then
               begin

               xline            :=df;

               end;

            end

         //.4 folder              =not build folder OR not on same drive -> leave as is
         else begin

            df                  :=xline;

            end;

         //get
         if xcanadd(df) then
            begin

            xok                 :=io__fileexists( df );

            if xok and (xdocType=pub_fText) then xaddWordCount( df );

            d.sadd( fmarker(xok) + #32 + insstr(pub_chapterOneMarker,dchapterOne) + insstr(pub_noFormatMarker,not dformatDocument) + xline + #10 );

            end;

         end

      //line is a relative filename "abc.txt"
      else if not low__havechar(xline,':') then
         begin

         df                     :=xbuildFolder + xline;

         if xcanadd(df) then
            begin

            xok                 :=io__fileexists( df );

            if xok and (xdocType=pub_fText) then xaddWordCount( df );

            d.sadd( fmarker(xok) + #32 + insstr(pub_chapterOneMarker,dchapterOne) + insstr(pub_noFormatMarker,not dformatDocument) + xline + #10 );

            end;

         end;

      end

   else begin

      xwithin                   :=strmatch(xline,pub_docFiles);

      end;

   end;

end;//loop

//fallback -> include current folder documents by default
if (d.len32<=0) then
   begin

   //.cover.bmp/jpg/png - auto. include - 23oct2026
   if faddOK('cover.bmp') or faddOK('cover.jpg') or faddOK('cover.jif') or faddOK('cover.jpeg') or faddOK('cover.png') then
      begin

      //nil

      end;

   //.doc files
   l                            :=tdynamicstring.create;

   io__filelist( l ,false ,xbuildFolder ,pub_docMask ,pub_docEMask );

   l.sort( true );

   for p:=0 to pred(l.count) do
   begin

   if (l.value[p]<>'') and xcanadd(l.value[p]) then
      begin

      d.sadd( fmarker(true) + #32 + l.value[p] + #10 );

      if (xdocType=pub_fText) then xaddWordCount( xbuildFolder + l.value[p] );

      end;

   end;//p

   end;

//set
result                          :=d.text;

except;end;

//free
faststr__free(@d);
freeobj(@a);
freeobj(@l);
freeobj(@w);

end;

procedure pub__FilterBuildFile(const xbuildFile:string);
var
   e                            :string;
   str1                         :string;

begin

pub__build2(xbuildFile,false,str1,e);

end;

function pub__build(const xbuildFile:string;var xoutputFilename,e:string):boolean;
begin

result                          :=pub__build2(xbuildFile ,true ,xoutputFilename ,e );

end;

function pub__build2(const xbuildFile:string;const xbuildPub:boolean;var xoutputFilename,dbuildStatus:string):boolean;
label
   skipone,skipdone,skipend;

var
   s                            :tfastvars2;
   sdata                        :string;
   slen                         :longint32;
   spos                         :longint32;
   sline                        :string;
   binuse                       :boolean;
   dfileCount                   :longint32;
   d                            :tstr8;
   l                            :tstr8;
   dbuildFolder                 :string;
   b                            :tpubinfo;
   etmp                         :string;
   v                            :string;
   v32                          :longint32;
   p                            :longint32;
   dcoverImageDone              :boolean;
   dformatDocument              :boolean;
   dchapterOne                  :boolean;
   v64                          :longint64;

   procedure ladd(x:string);
   begin

   //get
   x                            :=stripwhitespace_lt( x );

   if (x<>'') then
      begin

      swapchars( x ,#10,#32);
      swapchars( x ,#13,#32);
      swapchars( x ,#9 ,#32);

      x                         :=stripwhitespace_lt( x );

      end;

   //set
   d.sadd( x + pub_returnCode );

   end;

   procedure fadd(const n,v:string);
   begin

   ladd( n + ': ' + v );

   end;

   procedure dadd2(const n,vdef:string);
   begin

   ladd( n + ': ' + strdefb(s.s[n],vdef) );

   end;

   procedure dadd(const n:string);
   begin

   dadd2(n,'');

   end;

   procedure iadd(const n:string;const xmin,xmax,xdef:longint32);//17oct2026
   begin

   ladd( n + ': ' + k64(  pub__buildOptionValue( s.s[n] ,xmin ,xmax ,xdef )  ) );

   end;

   procedure badd(const n:string;const xdef:boolean);//17oct2026
   begin

   ladd( n + ': ' + bolstr(  pub__buildOptionBool( s.s[n] ,xdef )  ) );

   end;

   procedure dsave(const xmakepub,xbuildOK:boolean);
   var
      dlist                     :string;
      ddate                     :tdatetime;
      yy                        :word;
      mm                        :word;
      dd                        :word;
      dwordcount                :longint32;
      str1                      :string;

   begin

   ddate                        :=date__now;

   low__decodedate2( ddate ,yy ,mm ,dd );

   s.text                       :=sdata;

   d.clear;

   ladd(pub_buildSummary);

   if xmakepub then
      begin

      fadd ('Build.Status',dbuildStatus );
      fadd ('Build.Warning',low__aorbstr('(none)',b.firstError,(b.firstError<>'')) );
      fadd ('Build.Date',low__datestr(ddate,0,false) + ' @ '+low__timestr(ddate,0) );

      end

   else begin

      dadd2('Build.Status','(none)');
      dadd2('Build.Warning','(none)');
      dadd2('Build.Date','(none)');

      end;

   dlist                        :=pub__documentFileList( io__asfolder(io__extractfilepath(xbuildfile)) ,sdata ,xmakepub ,dwordcount );

   //.build number
   case s.found('build.number') of
   true:str1                    :=k64( pub__safeBuildNumber(add64( insint(1,xmakepub and xbuildOK) ,frcmin64(s.c['build.number'],pub_buildNumber_min) )) );
   else str1                    :=k64( pub__safeBuildNumber( pub_buildNumber_def ) );
   end;//case

   fadd('Build.Number',str1);//17oct2026

   fadd ('Build.Output.File',io__remlastext(io__extractfilename(xbuildFile))+'.epub');

   fadd ('Build.Engine.Version',pub__version);

   fadd('EPUB.File.Size',low__mbAUTO2( frcmin64(io__filesize64(io__remlastext(xbuildFile)+'.epub'),0) ,3 ,true ));

   if xmakepub then fadd('EPUB.Word.Count',k64(dwordcount))
   else             dadd2('EPUB.Word.Count','0');

   if xmakepub then fadd('File.Count',k64(dfileCount))
   else             dadd2('File.Count','0');

   //.book and author info

   ladd('');
   ladd('-- Book and Author Information --');
   fadd('Book.Title', windows1252__xmlFilterLine(pub__asTitle( s.s['book.title'],io__remlastext(io__extractfilename(xbuildFile)) ) ));

   dadd2('Author.First.Name','(first name)');
   dadd2('Author.Last.Name','(last name)');

   fadd('Publisher' ,windows1252__xmlFilterLine(pub__publisher(s.s['publisher']) ));

   dadd('Rights');
   dadd('ISBN');
   dadd('Des');
   dadd('Subject');
   dadd2('Release.Year',intstr32(frcmin32(yy,0)));
   dadd2('Release.Month',intstr32(frcrange32(mm,1,12)));
   dadd2('Release.Day',intstr32(frcrange32(dd,1,31)));

   //.build options
   ladd('');
   ladd('-- Build Options --');
   iadd('Header.VPad%'       ,pub_headerVPad_min       ,pub_headerVPad_max        ,pub_headerVPad_def        );
   iadd('Header.Size%'       ,pub_headerSize_min       ,pub_headerSize_max        ,pub_headerSize_def        );
   iadd('Header.Align'       ,pub_headerAlign_min      ,pub_headerAlign_max       ,pub_headerAlign_def       );

   iadd('Text.VPad%'         ,pub_textVPad_min         ,pub_textVPad_max          ,pub_textVPad_def          );
   iadd('Text.Size%'         ,pub_textSize_min         ,pub_textSize_max          ,pub_textSize_def          );
   iadd('Text.Justify'       ,pub_textJustify_min      ,pub_textJustify_max       ,pub_textJustify_def       );
   iadd('Line.Height%'       ,pub_lineHeight_min       ,pub_lineHeight_max        ,pub_lineHeight_def        );

   iadd('Drop.Caps'          ,pub_dropCaps_min         ,pub_dropCaps_max          ,pub_dropCaps_def          );
   iadd('Indent.Chars'       ,pub_indentChars_min      ,pub_indentChars_max       ,pub_indentChars_def       );
   iadd('Blank.Line'         ,pub_blankLine_min        ,pub_blankLine_max         ,pub_blankLine_def         );

   iadd('Format.Up'          ,pub_formatUp_min         ,pub_formatUp_max          ,pub_formatUp_def          );
   iadd('Scene.Sep'          ,pub_sceneSep_min         ,pub_sceneSep_max          ,pub_sceneSep_def          );
   iadd('Quotes.Single'      ,pub_quotesSingle_min     ,pub_quotesSingle_max      ,pub_quotesSingle_def      );
   iadd('Quotes.Double'      ,pub_quotesDouble_min     ,pub_quotesDouble_max      ,pub_quotesDouble_def      );

   iadd('Image.Conversion'   ,pub_imageConversion_min  ,pub_imageConversion_max   ,pub_imageConversion_def   );

   //.doc files
   ladd('');
   ladd(pub_docFiles);

   if (dlist<>'') then d.sadd( dlist );

   //.trailing blank line
   ladd('');

   //.save to file
   io__tofile( xbuildFile ,@d ,etmp );

   end;

   function m(const n:string):boolean;
   begin

   result                       :=strmatch( n ,sline );

   end;

   function mv(const x:string):boolean;
   var
      p                         :longint32;

   begin

   result                       :=strm(sline,x,v,v32);

   if (v<>'') then
      begin

      for p:=1 to low__len32(v) do if (v[p-1+stroffset]=':') then
         begin

         v                      :=strcopy1( v ,p+1 ,low__len32(v) );

         break;

         end;//p

      v                         :=stripwhitespace_lt( v );
      v32                       :=strint32( v );

      end;

   end;

   function zadd(const dname,ddata:string;const dstoreOnly:boolean):boolean;
   var
      v               :tstr8;

   begin

   //defaults
   result             :=false;
   v                  :=nil;

   try

   //init
   v                  :=faststr__new8;
   v.text             :=ddata;

   //get
   result             :=zip__add2( d ,l ,dname ,v ,dstoreOnly );

   except;end;

   //free
   faststr__free(@v);

   end;

   function ziadd(const drootfolder:string;const dslot:longint32;const dstoreOnly:boolean):boolean;
   begin

   //defaults
   result             :=false;

   //get
   if (dslot>=0) and (dslot<b.count) and (b.style[dslot]<>pub_none) then
      begin

      result          :=zadd( drootfolder + b.name[dslot] ,b.data[dslot] ,dstoreOnly );

      end;

   end;

begin

//defaults
result                          :=false;
dbuildStatus                    :=pub_buildOK;
binuse                          :=false;
s                               :=nil;
d                               :=nil;
l                               :=nil;
dfileCount                      :=0;
dcoverImageDone                 :=false;
dformatDocument                 :=true;

//check
if not io__fileexists( xbuildFile ) then
   begin

   dbuildStatus                 :=pub_buildFailed + gecFileNotfound;

   exit;

   end;

try


//init -------------------------------------------------------------------------

s                               :=tfastvars2.create;
d                               :=faststr__new8;
dbuildFolder                    :=io__extractfilepath( xbuildFile );
xoutputFilename                 :=pub__asEbookFilename( xbuildFile );


//filter build file ------------------------------------------------------------

sdata                           :=io__fromfilestr2( xbuildFile );
slen                            :=low__len32( sdata );
dsave(false,true);

if not xbuildPub then goto skipdone;


//build.init -------------------------------------------------------------------

binuse                          :=true;

pub__init( b ,dbuildFolder );//once "b.init" it must be "b.free" - 20oct2026


//build.read.settings ----------------------------------------------------------

//init
spos                            :=0;

//get
while low__nextline1( sdata ,sline ,slen ,spos ) do
begin

//.found first document file name -> stop
if pub__isDocumentFile(sline) then break;

//.book and author information
if      mv('book.title')                 then b.title:=v
else if mv('author.first.name')          then b.fname:=v
else if mv('author.last.name')           then b.lname:=v
else if mv('release.year')               then b.year:=v32
else if mv('release.month')              then b.month:=v32
else if mv('release.day')                then b.day:=v32
else if mv('rights')                     then b.rights:=v
else if mv('subject')                    then b.subject:=v
else if mv('des')                        then b.des:=v
else if mv('publisher')                  then b.publisher:=v
else if mv('isbn')                       then b.isbn:=v

//.build options
else if mv('header.size%')               then b.headerSize           :=pub__buildOptionValue( v ,pub_headerSize_min       ,pub_headerSize_max       ,pub_headerSize_def       )
else if mv('header.align')               then b.headerAlign          :=pub__buildOptionValue( v ,pub_headerAlign_min      ,pub_headerAlign_max      ,pub_headerAlign_def      )
else if mv('header.vpad%')               then b.headerVPad           :=pub__buildOptionValue( v ,pub_headerVPad_min       ,pub_headerVPad_max       ,pub_headerVPad_def       )

else if mv('text.size%')                 then b.textSize             :=pub__buildOptionValue( v ,pub_textSize_min         ,pub_textSize_max         ,pub_textSize_def         )
else if mv('text.vpad%')                 then b.textVPad             :=pub__buildOptionValue( v ,pub_textVPad_min         ,pub_textVPad_max         ,pub_textVPad_def         )
else if mv('line.height%')               then b.lineHeight           :=pub__buildOptionValue( v ,pub_lineHeight_min       ,pub_lineHeight_max       ,pub_lineHeight_def       )
else if mv('text.justify')               then b.textJustify          :=pub__buildOptionValue( v ,pub_textJustify_min      ,pub_textJustify_max      ,pub_textJustify_def      )


else if mv('indent.chars')               then b.indentChars          :=pub__buildOptionValue( v ,pub_indentChars_min      ,pub_indentChars_max      ,pub_indentChars_def      )
else if mv('blank.line')                 then b.blankLine            :=pub__buildOptionValue( v ,pub_blankLine_min        ,pub_blankLine_max        ,pub_blankLine_def        )
else if mv('drop.caps')                  then b.dropCaps             :=pub__buildOptionValue( v ,pub_dropCaps_min         ,pub_dropCaps_max         ,pub_dropCaps_def         )

else if mv('format.up')                  then b.formatUp             :=pub__buildOptionValue( v ,pub_formatUp_min         ,pub_formatUp_max         ,pub_formatUp_def         )
else if mv('scene.sep')                  then b.sceneSep             :=pub__buildOptionValue( v ,pub_sceneSep_min         ,pub_sceneSep_max         ,pub_sceneSep_def         )
else if mv('quotes.Single')              then b.quotesSingle         :=pub__buildOptionValue( v ,pub_quotesSingle_min     ,pub_quotesSingle_max     ,pub_quotesSingle_def     )
else if mv('quotes.Double')              then b.quotesDouble         :=pub__buildOptionValue( v ,pub_quotesDouble_min     ,pub_quotesDouble_max     ,pub_quotesDouble_def     )

else if mv('image.conversion')           then b.imageConversion      :=pub__buildOptionValue( v ,pub_imageConversion_min  ,pub_imageConversion_max  ,pub_imageConversion_def  )
else if mv('build.number')               then b.buildNumber          :=pub__safeBuildNumber( add64(1 ,pub__buildOptionValue( v ,pub_buildNumber_min      ,pub_buildNumber_max      ,pub_buildNumber_def) ));//must inc +1 here as its not incremented until AFTER epub is built - 20oct2026

end;//loop


//build.make.documents ---------------------------------------------------------

//init
spos                            :=0;

//get
while low__nextline1( sdata ,sline ,slen ,spos ) do
begin

if pub__isDocumentFile(sline) then
   begin

   //.inc
   inc( dfileCount );//20oct2026

   sline                        :=io__readportablefilename( pub__extractDocumentFile( sline ,dformatDocument ,dchapterOne ) );

   //.perDocumentSync
   pub__makestrs( b ,dformatDocument );

   if (io__extractfilepath(sline)='') then
      begin

      sline                     :=dbuildFolder + sline;

      end;

   //.cover image
   if not dcoverImageDone then
      begin

      dcoverImageDone           :=true;

      pub__addCoverOrImage( b ,sline ,true ,dchapterOne );

      end

   //.document text
   else begin

      pub__addDocument( b ,sline ,dformatDocument ,dchapterOne );

      end;

   end;

skipone:

end;


//.formatting OFF for the following documents - 24oct2026
pub__makestrs( b ,false );

//.uuid
b.uuid                          :=pub__uuid(b);

//.contents
pub__addContents( b );

//.contents.opf
pub__addContentopf( b );

//.stylesheet
pub__addStylesheet( b );

//.toc.ncx
pub__addTOCncx( b );


//build epub (.zip) ------------------------------------------------------------

//init
l                               :=faststr__new8;
d.clear;
zip__start( d ,l );

//get

zadd( 'mimetype' ,pub__mimetype      ,true );

zadd( 'META-INF/container.xml'       ,utf8__fromWin1252StrB( pub__containerxml ) ,false );//utf-8

//.titlepage
ziadd( pub_OEBPS ,b.slot_titlepagexhtml ,false );

//.css
ziadd( pub_OEBPS ,b.slot_stylesheetcss ,false );

//.chapters
for p:=0 to pred(b.count) do if (b.style[p]=pub_html) or (b.style[p]=pub_xhtml) then ziadd( pub_OEBPS ,p ,false );

//.images
for p:=0 to pred(b.count) do if (b.style[p]=pub_image) or (b.style[p]=pub_coverjpg) then ziadd( pub_OEBPS ,p ,false );

//.indexs
ziadd( pub_OEBPS ,b.slot_contentshtml ,false );
ziadd( pub_OEBPS ,b.slot_tocncx ,false );
ziadd( pub_OEBPS ,b.slot_contentsopf ,false );

//set
zip__stop( d ,l );

if not io__tofile( xoutputFilename ,@d ,etmp ) then
   begin

   dbuildStatus                 :=pub_buildFailed + etmp;

   goto skipend;

   end;

//successful -------------------------------------------------------------------

skipdone:
result                          :=true;
skipend:

//.update build file with status + build date
if xbuildPub then
   begin

   if (b.firstChapterIndex<0) then pub__setFirstError(b,'No file marked as chapter one (use a leading greater than symbol "'+pub_chapterOneMarker+'" before file name)');

   if result then dbuildStatus  :=pub_buildOK + insstr(' with warnings',b.firstError<>'');

   dsave(true,result);

   end;

except;end;

//free
if (s<>nil)  then freeobj(@s);
if (d<>nil)  then faststr__free(@d);
if (l<>nil)  then faststr__free(@l);
if binuse    then pub__free(b);

end;

function pub__isDocumentFile(const x:string):boolean;
var
   bol1                         :boolean;
   bol2                         :boolean;

begin

pub__extractDocumentFile2( x ,result ,bol1 ,bol2 );

end;

function pub__extractDocumentFile(const x:string;var xformatDocument,xchapterOne:boolean):string;
var
   xhasFileMarker               :boolean;

begin

result                          :=pub__extractDocumentFile2( x ,xhasFileMarker ,xformatDocument ,xchapterOne );

end;

function pub__extractDocumentFile2(const x:string;var xhasFileMarker,xformatDocument,xchapterOne:boolean):string;

   function mv(const n:string;var v:string):boolean;
   begin

   result                       :=strmatch( strcopy1(v,1,low__len32(n)) ,n );

   if result then
      begin

      xhasFileMarker            :=true;
      
      v                         :=stripwhitespace_lt( strcopy1( v ,succ(low__len32(n)) ,low__len32(v) ) );

      end;

   end;

   procedure xcheckForMark;
   label
      redo;

   var
      bol1                      :boolean;

   begin

   redo:

   bol1                         :=false;

   if (strcopy1(result,1,1)=pub_noFormatMarker) then
      begin

      xformatDocument           :=false;//switch off formatting for this document

      strdel1(result,1,1);

      result                    :=stripwhitespace_lt( result );
      bol1                      :=true;

      end;

   if (strcopy1(result,1,1)=pub_chapterOneMarker) then
      begin

      xchapterOne               :=true;//indicate this document is chapter one

      strdel1(result,1,1);

      result                    :=stripwhitespace_lt( result );
      bol1                      :=true;

      end;

   //loop
   if bol1 then goto redo;

   end;

begin

//defaults
result                          :=x;
xhasFileMarker                  :=false;
xformatDocument                 :=true;
xchapterOne                     :=false;

//get
case mv( pub_fileMarker ,result ) or mv( pub_fileMarkerOK ,result ) or mv( pub_fileMarkerNotFound ,result ) of

true:xcheckForMark;
else xcheckForMark;

end;//case

end;

function pub__preprocess(var xcore:tpubinfo;const xfilename:string;const dformatDocument:boolean):boolean;
label
   skipone,skipend;

var
   etmp                         :string;
   p                            :longint32;
   ff                           :tfastfont;
   fc                           :tfastchar;
   flinespacing                 :longint32;
   dstartPos                    :longint32;
   dheadTo                      :longint32;
   bol1                         :boolean;
   lc                           :longint32;
   xfrom                        :longint32;
   dstartLine                   :boolean;
   dfirstLine                   :boolean;
   dskipTill                    :longint32;

   ddropCapOne                  :longint32;//single large letter OR symbol + letter - 23oct2026
   ddropCapOneTo                :longint32;

   ddropCapsFrom                :longint32;//upto first 3 words in small caps
   ddropCapsTo                  :longint32;
   ddropCapsWordCount           :longint32;

   procedure a(const c:longint32);
   begin

   xcore.s.addint4( c  );

   end;

   procedure sa(const c:longint32;const newChar:byte);
   begin

   if (c>=1) and (c<=xcore.tlen) then xcore.t.data.bytes[pred(c)]:=newChar;

   xcore.s.addint4( c  );

   end;

   procedure astr(const c:string);
   var
      p               :longint32;

   begin

   for p:=1 to low__len32(c) do a(byte( c[p-1+stroffset] ));

   end;

   function tc(const xpos1:longint32):byte;
   begin

   if (xpos1>=1) and (xpos1<=xcore.tlen) then result:=xcore.t.data.bytes[pred(xpos1)]
   else                                       result:=10;

   end;

   function tstr(const xpos1,xlen:longint32):string;
   var
      p                         :longint32;
      i                         :longint32;

   begin

   //check
   if (xlen<=0) then
      begin

      result                    :='';

      exit;

      end;

   //init
   low__setlen( result ,xlen );
   i                            :=1;

   //get
   for p:=xpos1 to pred(xpos1+xlen) do
   begin

   result[ i - 1 + stroffset ]  :=char( tc( p ) );

   inc( i );

   end;//p

   end;

   function xfindAlign(const xpos:longint32):longint32;
   begin

   result                       :=xcore.t.xfastfindalign( xpos );//scan to end of line for alignment code - 16oct2026

   end;

   procedure xstopline;//stop line
   begin

   if dstartLine then
      begin

      dstartLine                :=false;

      a( pub_stopLine );

      end;

   end;
   
begin


//defaults
result                          :=false;
dstartPos                       :=1;
dheadTo                         :=0;

ddropCapOne                     :=0;
ddropCapOneTo                   :=0;

ddropCapsFrom                   :=0;
ddropCapsTo                     :=0;
ddropCapsWordCount              :=0;


//init -------------------------------------------------------------------------

with xcore do
begin

s.clear;
tlen                            :=0;
docHeading                      :='';

end;


//read doc from file -----------------------------------------------------------

if not io__fromfile( xfilename ,@xcore.s ,etmp ) then
   begin

   pub__setFirstError( xcore ,'File not found: '+xfilename);

   goto skipend;

   end;

xcore.t.iosetdata( xcore.s );
xcore.s.clear;

xcore.tlen                      :=xcore.t.len32;

xcore.t.xfastcharinit( ff );


//formatting -------------------------------------------------------------------

//.sceneSep
pub__formatSceneSep( xcore.t.data ,xcore.sceneSep );

//.formatUP
if (xcore.formatUp>=1) then pub__formatUp( xcore.t.data );

//.quotesSingle
case xcore.quotesSingle of

1:pub__quotesSinglePlain( xcore.t.data );//plain/straight
2:pub__quotesSingleCurly( xcore.t.data );//curly

end;//case

//.quotesDouble
case xcore.quotesDouble of

1:pub__quotesDoublePlain( xcore.t.data );//plain/straight
2:pub__quotesDoubleCurly( xcore.t.data );//curly

end;//case


//find start of page -----------------------------------------------------------

for p:=1 to frcmax32( xcore.tlen ,pub_preprocessingScanLen ) do
begin

xcore.t.xfastchar( ff, p ,flinespacing ,fc );

if (fc.cs=wc_i) then
   begin

   dstartPos          :=p;
   break;

   end;

if (fc.cs=wc_t) and windows1252__charVisible(fc.c) then
   begin

   dstartPos          :=p;
   break;

   end;

end;//p


//find page heading ------------------------------------------------------------

bol1                  :=false;

for p:=dstartPos to frcmax32(xcore.tlen,pub_preprocessingScanLen) do
begin

xcore.t.xfastchar( ff, p ,flinespacing ,fc );

if (fc.cs=wc_t) then
   begin

   case fc.c of

   10:if bol1 then break;

   else if windows1252__charVisible(fc.c) or (fc.c=32) or (fc.c=160) then
      begin

      bol1                                :=true;
      dheadTo                             :=p;
      xcore.docHeading                    :=xcore.docHeading + char(fc.c);

      end;

   end;//case

   end

else if (fc.cs=wc_i) then
   begin

   dheadTo                                :=p;
   break;

   end;


end;//p


//header processing ------------------------------------------------------------

if (dheadTo>=dstartPos) then
   begin

   //start
   a( pub_startLineHeader );

   lc                           :=10;

   //get
   for p:=dstartPos to dheadTo do
   begin

   xcore.t.xfastchar( ff, p ,flinespacing ,fc );

   //.image
   if      (fc.cs=wc_i) then
      begin

      a( p )

      end

   //.text
   else if (fc.cs=wc_t) then
      begin

      //.text character
      case fc.c of

      32,160                         :if (lc<>32) and (lc<>160) then sa(p,32);//single standard space

      else if (fc.c>=32) then         a(p);

      end;//case

      end;

   //.last character
   lc                             :=fc.c;

   end;//p

   //stop
   a( pub_stopLine );

   end;


//drop caps processing ---------------------------------------------------------

if (xcore.ddropCaps>=1) then
   begin

   //init
   lc                           :=10;

   //get
   for p:=succ(largest32(dstartPos,dheadTo)) to xcore.tlen do
   begin

   xcore.t.xfastchar( ff, p ,flinespacing ,fc );

   //.stop
   if (fc.c=10) and (ddropCapsFrom>=1) then break;

   //.decide
   if (fc.cs=wc_t) then
      begin

      case xcore.ddropCaps of

      1..2:if windows1252__charVisible(fc.c) then
           begin

           if (ddropCapOne=0) then
              begin

              if (xfindAlign(p+1)=0) then
                 begin

                 ddropCapOne    :=p;//23oct2026
                 ddropCapOneTo  :=p;

                 end

              else break;

              end;

           if (ddropCapOne>=1) and windows1252__charIsLetter(fc.c) then
              begin

              ddropCapOneTo  :=p;

              break;

              end;


           end;

      3..pub_dropcaps_max:begin

         //cancel
         if (xfindAlign(p+1)<>0) then break;

         //start
         if windows1252__charVisible(fc.c) and (ddropCapsFrom=0) then
            begin

            ddropCapsFrom       :=p;

            end;

         //stop
         ddropCapsTo            :=p;

         if ((fc.c=32) or (fc.c=160)) and (lc<>32) and (lc<>160) then
            begin

            inc( ddropCapsWordCount );

            if (ddropCapsWordCount>=xcore.ddropWordLimit) then break;

            end;

         end;

      end;//case

      end;//t

   //.lc
   lc                              :=fc.c;

   end;//p

   end;//if


//body text processing ---------------------------------------------------------

//init
lc                           :=10;
dfirstLine                   :=false;
dstartLine                   :=false;
dskipTill                    :=0;
xfrom                        :=succ(largest32(dstartPos,dheadTo));

//get
for p:=xfrom to xcore.tlen do
begin

//.skip
if (p<=dskipTill) then goto skipone;

//.read character
xcore.t.xfastchar( ff, p ,flinespacing ,fc );

//.start line
if (not dstartline) and  ( (fc.cs=wc_i) or ((fc.cs=wc_t) and windows1252__charVisible(fc.c)) ) then
   begin

   //.start the line of text
   if (xcore.dblankLine>=1) and dfirstLine then a( pub_blankLine );

   dstartline                   :=true;
   lc                           :=10;

   case ( dfirstLine or (xcore.dindentFirst>=1) ) and (xcore.dindentChars>=1) of

   true:begin

      case xfindAlign( p ) of

      0   :a(pub_startLineIndentL);
      1   :a(pub_startLineIndentC);
      2   :a(pub_startLineIndentR);
      else a(pub_startLineIndentL);

      end;//case

      end;

   else begin

      case xfindAlign( p ) of

      0   :a(pub_startLineL);
      1   :a(pub_startLineC);
      2   :a(pub_startLineR);
      else a(pub_startLineL);

      end;//case

      end;

   end;//case

   dfirstline                   :=true;

   end;

//.image
if      (fc.cs=wc_i) then
   begin

   a( p );

   end

//.text
else if (fc.cs=wc_t) then
   begin

   //.start drop.caps
   if      (p = ddropCapOne ) then
      begin

      if ( ddropCapOne >= 1 ) then a( pub_startDropCapOne );

      end

   else if ( ddropCapsFrom >= 1 ) and ( p >= ddropCapsFrom ) then
      begin

      ddropCapsFrom             :=0;//off

      a( pub_startDropCaps );

      end;

   //.text
   case fc.c of

   10                                :xstopline;//stop line
   32,160                            :if (lc<>32) and (lc<>160) then sa(p,32);//single standard space

   else if (fc.c>=32) then           a(p);

   end;//case

   //.stop drop.caps
   if      ( p = ddropCapOneTo ) then
      begin

      if ( ddropCapOne >= 1 ) then a( pub_stopDropCaps );

      end

   else if ( ddropCapsTo >= 1 ) and ( p >= ddropCapsTo ) then
      begin

      ddropCapsTo               :=0;//off

      a( pub_stopDropCaps );

      end;

   end

//.special codes
else begin

   case fc.c of

   pub_sceneSep0                :sa( pub_sceneSep ,pub_unusedChar );

   end;//case

   end;

//.last character
lc                             :=fc.c;

skipone:

end;//p

//.finalise
if dstartLine then
   begin

   a( pub_stopLine );

   end;

//successful
result                                    :=true;

skipend:

end;

function pub__addCoverOrImage(var xcore:tpubinfo;const xfilename:string;const xAsCover,dchapterOne:boolean):boolean;
label
   skipend;

var
   p                            :longint32;
   ff                           :tfastfont;
   fc                           :tfastchar;
   flinespacing                 :longint32;
   etmp                         :string;
   dindex                       :longint32;
   xformat                      :string;
   xbase64                      :boolean;
   xdocType                     :longint32;
   dmode                        :longint32;

   function xDefaultOrSkipped:string;
   begin

   case xAsCover of
   true:result:='Default cover used.';
   else result:='Image skipped.';
   end;//case

   end;

   procedure dmarkAsChapterOne(const dindex:longint32);
   begin

   if dchapterOne and ((dmode=pub_isImageAsDoc) or (dmode=pub_isImageCover)) then
      begin

      pub__setChapterOneOnce( xcore ,dindex );

      end;
      
   end;

begin

//defaults
result                          :=false;
dmode                           :=low__aorb( pub_isImageAsDoc ,pub_isImageCover ,xAsCover );

try


//init -------------------------------------------------------------------------

with xcore do
begin

s.clear;
docHeading                      :='';

end;


//check file format ------------------------------------------------------------

pub__fileFormatSupported2( xfilename ,xdocType );

if (xdocType=pub_fNone) then
   begin

   pub__setFirstError(xcore,'Unsupported file type: '+xfilename+'. Default cover used.');

   goto skipend;

   end;


//read file from disk ----------------------------------------------------------

if not io__fromfile( xfilename ,@xcore.s ,etmp ) then
   begin

   pub__setFirstError( xcore ,'File not found: '+xfilename+'. '+xDefaultOrSkipped);

   goto skipend;

   end;


//file is an image file --------------------------------------------------------

if (xdocType=pub_fImage) then
   begin

   case mis__format( @xcore.s, xformat, xbase64) of

   true:result        :=pub__addImage2( xcore ,xfilename ,xcore.s ,dmode ,dindex );

   else pub__setFirstError(xcore,'Image corrupt: '+xfilename+'. '+xDefaultOrSkipped);

   end;//case

   if result then dmarkAsChapterOne(dindex);//mark as chapter one

   goto skipend;

   end;


//file is a document -> extract FIRST IMAGE in document for cover --------------

if xAsCover then
   begin

   xcore.t.iosetdata( xcore.s );
   xcore.t.xfastcharinit( ff );

   for p:=1 to xcore.t.len32 do
   begin

   xcore.t.xfastchar( ff, p ,flinespacing ,fc );

   if (fc.cs=wc_i) then
      begin

      result             :=pub__addImage2( xcore ,xfilename ,xcore.t.ilist[fc.wid].orgdata ,dmode ,dindex );

      if result then dmarkAsChapterOne(dindex);//mark as chapter one

      goto skipend;

      end;

   end;//p

   end;


//fallback ---------------------------------------------------------------------
skipend:

if (not result) and xAsCover then
   begin

   pub__setFirstError(xcore,'No image found in first file. Default cover used.');

   pub__coverImageDefault( xcore.s );

   if pub__addImage2( xcore ,xfilename ,xcore.s ,dmode ,dindex ) then
      begin

      dmarkAsChapterOne(dindex);//mark as chapter one

      end;
      
   end;

except;end;

//clear
xcore.s.clear;

end;

function pub__addDocument(var xcore:tpubinfo;const xfilename:string;const dformatDocument,dchapterOne:boolean):boolean;
label
   addImage, addText, addfile, redo, skipend;

var
   p                            :longint32;
   etmp                         :string;
   ff                           :tfastfont;
   fc                           :tfastchar;
   flinespacing                 :longint32;
   dbold                        :boolean;
   ditalic                      :boolean;
   dunderline                   :boolean;
   dstrikeout                   :boolean;
   dindex                       :longint32;
   dpos                         :longint32;
   v                            :longint32;
   slen                         :longint32;
   tlen                         :longint32;
   dsmallCapsActive             :boolean;
   xdocType                     :longint32;
   dlinkStart                   :longint32;
   dlinkData                    :tstr8;
   
   procedure ladd(const v:string);
   begin

   xcore.docText.sadd( v + pub_returnCode );

   end;

   procedure radd(const v:string);
   begin

   if (v<>'') then xcore.docText.sadd( v );

   end;

   procedure dstyle(const xbold,xitalic,xunderline,xstrikeout:boolean);
   var
      r                         :string;

      procedure a(const v:string);
      begin

      if (v<>'') then
         begin

         r  :=r + insstr( '<span class="' ,(r='') ) + insstr(#32,r<>'') + v;

         end;

      end;


   begin

   //stop previous
   if dbold or ditalic or dunderline or dstrikeout then
      begin

      radd('</span>');

      end;

   //init
   dbold                        :=xbold;
   ditalic                      :=xitalic;
   dunderline                   :=xunderline;
   dstrikeout                   :=xstrikeout;
   r                            :='';

   //get
   if dbold                          then a('bb');
   if ditalic                        then a('ii');

   if      dunderline and dstrikeout then a('us')
   else if dunderline                then a('uu')
   else if dstrikeout                then a('ss');

   //set
   if (r<>'')                        then radd( r + '">' );

   end;

   procedure noStyle;
   begin

   //stop
   if dbold or ditalic or dunderline or dstrikeout then
      begin

      radd('</span>');

      end;

   //stop
   dbold                        :=false;
   ditalic                      :=false;
   dunderline                   :=false;
   dstrikeout                   :=false;

   end;

   function dpull(var x:longint32):boolean;
   begin

   //defaults
   result                       :=false;

   //get
   if ((dpos+3)<slen) then
      begin

      x                         :=xcore.s.int4[ dpos ];

      inc( dpos ,4 );

      result                    :=true;

      end;

   end;

   function dstr(const xshiftPos,xlen:longint32):string;
   var
      p                         :longint32;
      _pos                      :longint32;
      _v                        :longint32;

   begin

   //check
   if (xlen<=0) then
      begin

      result                    :='';

      exit;

      end;

   //init
   low__setlen( result ,xlen );
   _pos                         :=dpos;
   _v                           :=v;

   if (xshiftPos<>0) then
      begin

      dpos                      :=frcmin32( dpos + ( 4 * xshiftPos ) ,0 );

      end;

   //get
   for p:=1 to xlen do
   begin

   if dpull(v) and (v>=0) then
      begin

      xcore.t.xfastchar( ff, v ,flinespacing ,fc );

      result[ p - 1 + stroffset ]  :=char( fc.c );

      end

   else begin

      low__setlen( result ,p );

      break;

      end;

   end;//p

   //restore
   dpos                         :=_pos;
   v                            :=_v;

   if (v>=0) then xcore.t.xfastchar( ff, v ,flinespacing ,fc );

   end;

   procedure xstopLink;//22oct2026
   var
      v               :string;

      function xlabel:string;
      begin

      if strmatch(strcopy1(dlinkData.text,1,7),'mailto:') then result:='Link to an email address: '+windows1252__xmlFilterLine(pub__stripProtocols( strcopy1( v, succ(dlinkStart) ,xcore.docText.len32 ) ))
      else                                                     result:='Link to an external website: '+windows1252__xmlFilterLine(dlinkData.text);

      end;

   begin

   if (dlinkStart<>max32) then
      begin

      //get
      v                         :=xcore.docText.text;

      xcore.docText.text        :=

       strcopy1( v ,1 ,dlinkStart )                                                +

       '<a target="_blank" title="'+xlabel+'" href="'                              +
       net__encodeforhtmlstr(dlinkData.text)                                       +
       '">'                                                                        +

       //.auto strip protocols for visible portion of link:
       pub__stripProtocols( strcopy1( v, succ(dlinkStart) ,xcore.docText.len32 ) ) +
       '</a>'                                                          ;

       //stopped
       dlinkStart         :=max32;
       dlinkData.clear;

       end;

   end;

   function xcanStartLink:boolean;
   begin

   result             :=(dlinkStart=max32);

   end;

   procedure xstartLink(const xpos:longint32);
   begin

   if xcanStartLink and (xpos>=1) then
      begin

      dlinkStart      :=xpos;
      dlinkData.clear;

      end;

   end;

   procedure xAutoStartLink;
   var
      str1            :string;

      function m(const xname:string):boolean;
      begin

      result          :=strmatch( xname ,strcopy1(str1,1,low__len32(xname)) );

      end;


   begin

   if xcanStartLink then
      begin

      str1            :=strlow( dstr( -1, 8) );

      if m('https://') or m('http://') or m('ftp://') or m('ftps://') or m('mailto:') then xstartLink( xcore.docText.len32 );

      end;

   end;

begin

//defaults
result                          :=false;

//init
xcore.docText.clear;
xcore.docHeading                :='';
tlen                            :=xcore.t.len32;
dbold                           :=false;
ditalic                         :=false;
dunderline                      :=false;
dstrikeout                      :=false;
dsmallCapsActive                :=false;
dlinkdata                       :=nil;

try

//decide -----------------------------------------------------------------------

pub__fileFormatSupported2( xfilename ,xdocType );

case xdocType of

pub_fImage :goto addImage;
pub_fText  :goto addText;
else if     pub__setFirstError(xcore,'Unsupported file type: '+xfilename+'. File skipped.') then goto skipend;

end;//case


//add image document -----------------------------------------------------------

addImage:

result                          :=pub__addCoverOrImage( xcore ,xfilename ,false ,dchapterOne );

goto skipend;


//add text document ------------------------------------------------------------

addText:

//.pre-process document
if not pub__preprocess( xcore ,xfilename ,dformatDocument ) then
   begin

   goto skipend;

   end;

slen                            :=xcore.s.len32;

//.start html
ladd('<?xml version="1.0" encoding="'+pub_utf8+'"?>');
ladd('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">');
ladd('<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" xmlns:xml="http://www.w3.org/XML/1998/namespace">');
ladd('');

ladd('<head>');
ladd('');

ladd('<meta http-equiv="content-type" content="text/html; charset='+pub_utf8+'"/>');
ladd('<meta content="http://www.w3.org/1999/xhtml; charset='+pub_utf8+'" http-equiv="content-type"/>');
ladd('<title>'+windows1252__xmlFilterLine(pub__title(xcore))+'</title>');
ladd('<link href="css/stylesheet.css" type="text/css" rel="stylesheet"/>');
ladd('<meta name="generator" content="'+windows1252__xmlFilterLine(pub__generator)+'"/>');
ladd('<meta name="author" content="'+windows1252__xmlFilterLine(pub__author(xcore))+'"/>');
ladd('<meta name="created" content="'+windows1252__xmlFilterLine(pub__releasedate(xcore))+'"/>');
ladd('<meta name="changed" content="'+windows1252__xmlFilterLine(pub__releasedate(xcore))+'"/>');
ladd('<meta name="info_1" content=""/>');
ladd('<meta name="info_2" content=""/>');
ladd('<meta name="info_3" content=""/>');
ladd('<meta name="info_4" content=""/>');

ladd('');
ladd(pub_pageStyleCode);

ladd('');
ladd('</head>');

ladd('');
ladd('<body>');

ladd('');


//get --------------------------------------------------------------------------

//init
dpos                            :=0;
dlinkStart                      :=max32;
dlinkData                       :=faststr__new8;

xcore.t.xfastcharinit( ff );

//get
redo:

if dpull(v) then
   begin

    //get
   case v of

   pub_blankLine                :begin

                                nostyle;

                                ladd( xcore.blankLineStr );

                                end;

   pub_startLineHeader          :begin

                                nostyle;
                                radd( xcore.startLineHeaderStr );

                                end;

   pub_startLineIndentL         :begin

                                nostyle;
                                radd( xcore.startLineIndentLStr );

                                end;

   pub_startLineIndentC         :begin

                                nostyle;
                                radd( xcore.startLineIndentCStr );

                                end;

   pub_startLineIndentR         :begin

                                nostyle;
                                radd( xcore.startLineIndentRStr );

                                end;

   pub_startLineL               :begin

                                nostyle;
                                radd( xcore.startLineLStr );

                                end;

   pub_startLineC               :begin

                                nostyle;
                                radd( xcore.startLineCStr );

                                end;

   pub_startLineR               :begin

                                nostyle;
                                radd( xcore.startLineRStr );

                                end;

   pub_stopline                 :begin

                                xstopLink;

                                nostyle;

                                ladd( xcore.stopLineStr );

                                end;

   pub_sceneSep                 :begin

                                nostyle;

                                if (xcore.dblankLine>=1) then ladd( xcore.blankLineStr );

                                ladd( xcore.sceneSepStr );

                                end;

   pub_skip                     :;

   pub_startDropCapOne          :begin

                                case xcore.ddropCaps of
                                1:radd( '<span class="abovechar">'  );
                                2:radd( '<span class="dropchar">'  );
                                end;//case

                                end;

   pub_startDropCaps            :begin

                                dsmallCapsActive    :=true;
                                radd( '<span class="smallcaps">' );

                                end;

   pub_stopDropCaps             :begin

                                dsmallCapsActive    :=false;

                                nostyle;//turn off all styles BEFORE stopping dropcaps STYLE

                                radd( '</span>'                  );

                                end;

   0..max32: begin

      xcore.t.xfastchar( ff, v ,flinespacing ,fc );

      //.stop link
      if (fc.cs<>wc_t) then
         begin

         xstopLink;

         end;

      //.style
      if (fc.cs<>wc_n) and ( ( dbold      <>xcore.t.tlist[fc.wid].bold       ) or
                             ( ditalic    <>xcore.t.tlist[fc.wid].italic     ) or
                             ( dunderline <>xcore.t.tlist[fc.wid].underline  ) or
                             ( dstrikeout <>xcore.t.tlist[fc.wid].strikeout  )
                             ) then
         begin

         dstyle(
         xcore.t.tlist[fc.wid].bold      ,
         xcore.t.tlist[fc.wid].italic    ,
         xcore.t.tlist[fc.wid].underline ,
         xcore.t.tlist[fc.wid].strikeout
         );

         end;

      //.text character
      if (fc.cs=wc_t) then
         begin

         //.link scanner - start
         case fc.c of

         llh,uuH ,llf,uuf ,llm,uum :xAutoStartLink;

         9,10,32,160               :xstopLink;

         end;//case

         //.dsmallCapsActive case filter -> do AFTER "link scanner.start", as the scanner resets "fc.c" - 23oct2026
         if dsmallCapsActive then
            begin

            case fc.c of
            lla..llz:dec(fc.c,32);//a -> A
            end;//case

            end;

         //.link raw char collector
         if (dlinkStart<>max32) then
            begin

            dlinkData.addbyt1( fc.c );

            end;

         //.text character
         case fc.c of

         32,160                           :radd(#32);//single spaces only
         else if (fc.c>=32) then           radd( char(fc.c) );

         end;//case

         end

      //.image
      else if (fc.cs=wc_i) then
         begin

         if pub__addImage( xcore ,xcore.t.ilist[fc.wid].orgdata ,pub_isImageData ,dindex ) then
            begin

            //scale image to fit within page dimensions - 20oct2026
            radd('<img alt="Inline Image" style="aspect-ratio:'+pub__single(xcore.t.ilist[fc.wid].h/frcmin32(xcore.t.ilist[fc.wid].w,1))+';max-width:100%;" src="'+xcore.name[dindex]+'" />');//the trailing back slash "/>" is required for Adobe Digital Editions to display multiple images without error - 17oct2026

            end;

         end;

      end;//begin

   end;//case

   //loop
   goto redo;

   end;//case

//.stop link
xstopLink;

//.stop html
ladd('');
ladd('</body>');

ladd('');
ladd('</html>');

//.addfile
result                          :=pub__addfile( xcore ,pub_html ,utf8__fromWin1252StrB( xcore.docText.text ) ,'' ,dindex );//utf-8

if result then
   begin

   if dchapterOne then pub__setChapterOneOnce( xcore ,dindex );

   xcore.headingRaw[dindex]     :=pub__asTitle( xcore.docHeading ,'' );

   end;

goto skipend;


//finish -----------------------------------------------------------------------

skipend:

except;end;

//error
if (not result) then pub__setFirstError(xcore,'Failed to make document: '+xfilename+'. File skipped.');

//free
if (dlinkdata<>nil) then faststr__free(@dlinkdata);

end;

function pub__addfile(var xcore:tpubinfo;const dstyle:longint32;const xdata,xrefData:string;var dindex:longint32):boolean;
var
   p                  :longint32;
   dname              :string;

begin

//defaults
result                :=false;
dindex                :=0;

//check
if (dstyle<=pub_none) then exit;

//find free slot
for p:=0 to high(xcore.style) do
begin

if (xcore.style[p]=pub_none) then
   begin

   //get
   xcore.style[p]     :=dstyle;

   case xcore.style[p] of

   pub_html        :begin

                   xcore.format[p]        :='html';
                   dname                  :='section' + pub__digPad(xcore.count_text) + '.html';
                   xcore.nval[p]          :=xcore.count_text;
                   inc( xcore.count_text);

                   end;

   pub_xhtml       :begin

                   xcore.format[p]        :='xhtml';
                   dname                  :='section' + pub__digPad(xcore.count_text) + '.xhtml';
                   xcore.nval[p]          :=xcore.count_text;
                   inc( xcore.count_text);

                   end;

   pub_titlePage   :begin

                   xcore.format[p]        :='xhtml';
                   dname                  :='titlepage.xhtml';

                   end;

   pub_contentshtml:begin

                   xcore.format[p]        :='html';
                   dname                  :='contents.html';

                   end;

   pub_contentopf  :begin

                   xcore.format[p]        :='opf';
                   dname                  :='content.opf';

                   end;

   pub_tocncx      :begin

                   xcore.format[p]        :='ncx';
                   dname                  :='toc.ncx';

                   end;

   pub_styleSheetcss:begin

                   xcore.format[p]        :='css';
                   dname                  :='css/stylesheet.css';

                   end;

   pub_image      :begin

                   xcore.format[p]        :=strlow( io__anyformatc(xdata) );
                   dname                  :='images/image' + pub__digPad(xcore.count_image) + '.'+xcore.format[p];
                   xcore.nval[p]          :=xcore.count_image;

                   inc( xcore.count_image);

                   end;

   pub_coverjpg   :begin

                   xcore.format[p]        :=strlow( io__anyformatc(xdata) );
                   dname                  :='images/cover' + '.'+xcore.format[p];

                   end;

   end;//case

   xcore.name[p]                          :=dname;
   xcore.nref[p]                          :=crc32__nonzero( dname );
   xcore.data[p]                          :=xdata;
   xcore.dataLen[p]                       :=low__len32(xdata);//19oct2026

   xcore.refdata[p]                       :=xrefData;
   xcore.refdataLen[p]                    :=low__len32(xrefData);//19oct2026

   inc( xcore.count );


   //xxxxxxxxxxxxxxxxx//????????????????????????????????????
   //xxxxxxxxxxxxxxxxx//?????????????????????????????????????
   //xxxxxxxxxxxxxxxxx//?????????????????????????????????????
   //xxxxxxxxxxxxxxxxx//?????????????????????????????????????
   //xxxxxxxxxxxxxxxxx//?????????????????????????????????????
   io__tofilestr2( xcore.buildFolder + 'test-ccc\' + dname ,xdata );//?????????????

   //successful
   result          :=true;
   dindex          :=p;

   //stop
   break

   end;

end;//p



end;

function pub__addImage(var xcore:tpubinfo;const simageStream:tstr8;const dimageStorageStyle:longint32;var dindex:longint32):boolean;
begin

result      :=pub__addImage2( xcore ,'' ,simageStream ,dimageStorageStyle ,dindex );

end;

function pub__addImage2(var xcore:tpubinfo;const simageFileNameForRefOnly:string;const simageStream:tstr8;const dimageStorageStyle:longint32;var dindex:longint32):boolean;
var
   d                  :tstr8;
   dtitle             :string;
   etmp               :string;
   lfirstimage        :boolean;
   dw                 :longint32;
   dh                 :longint32;

   function dneed:boolean;
   begin

   result             :=true;
   
   if (d=nil) then d  :=faststr__new8;

   end;

   function xalreadyHaveImage(const s:tstr8):boolean;
   var
      v               :string;
      slen            :longint32;
      vlen            :longint32;
      p               :longint32;

   begin

   //defaults
   result             :=false;

   //check
   if (s=nil) or (s.len32<=0) then exit;

   //init
   slen               :=s.len32;
   v                  :=s.str1[1,1000];
   vlen               :=low__len32(v);

   //find
   for p:=0 to pred(xcore.count) do
   begin

   if ((xcore.style[p]=pub_image) or (xcore.style[p]=pub_coverjpg)) and (slen=xcore.dataLen[p]) and (v=strcopy1(xcore.data[p],1,vlen)) then
      begin

      result          :=true;
      dindex          :=p;

      break;

      end;

   end;//p

   end;

   function xaddfile(var xcore:tpubinfo;const dstyle:longint32;const xdata,xrefData:string;var dindex:longint32;const dw,dh:longint32):boolean;
   begin

   result             :=pub__addfile( xcore ,dstyle ,xdata ,xrefData ,dindex );

   if result then
      begin

      xcore.w[dindex] :=dw;
      xcore.h[dindex] :=dh;

      end;

   end;

begin

//defaults
result                :=false;
dindex                :=0;
d                     :=nil;

try

//normal image
if (dimageStorageStyle=pub_isImageData) then
   begin

   case xalreadyHaveImage(simageStream) of

   true:result        :=true;
   else result        := dneed and pub__convertImage( xcore ,simageStream ,d ,false ,etmp ) and pub__enforceImageLimits( xcore ,d ,dw ,dh ) and
                                   ( xalreadyHaveImage(d) or xaddfile( xcore ,pub_image ,d.text ,simageStream.text ,dindex ,dw ,dh ) );
   end;//case

   end

//image as doc
else if (dimageStorageStyle=pub_isImageAsDoc) then
   begin

   //init
   case xalreadyHaveImage(simageStream) of

   true:result        :=true;
   else result        := dneed and pub__convertImage( xcore ,simageStream ,d ,false ,etmp ) and pub__enforceImageLimits( xcore ,d ,dw ,dh ) and
                                   ( xalreadyHaveImage(d) or xaddfile( xcore ,pub_image ,d.text ,simageStream.text ,dindex ,dw ,dh ) );
   end;//case

   //make image png or jpg
   if result then
      begin

      //init
      dtitle          :=pub__asTitle( io__remlastext(io__extractfilename( simageFileNameForRefOnly )) ,'' );

      //image0000.html
      d.text:=
      '<?xml version="1.0" encoding="'+pub_utf8+'"?>'+pub_returnCode+
      '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">'+pub_returnCode+
      '<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" xmlns:xml="http://www.w3.org/XML/1998/namespace">'+pub_returnCode+

      pub_returnCode+
      '<head>'+pub_returnCode+

      pub_returnCode+
      '<meta http-equiv="Content-Type" content="text/html; charset='+pub_utf8+'" />'+pub_returnCode+
      '<title>'+windows1252__xmlFilterLine(dtitle)+'</title>'+pub_returnCode+

      pub_returnCode+
      '<link href="css/stylesheet.css" type="text/css" rel="stylesheet"/>' + pub_returnCode +

      pub_returnCode+
      '</head>'+pub_returnCode+

      pub_returnCode+
      '<body>'+pub_returnCode+

      pub_returnCode+

      xcore.startLineHeaderStr + dtitle + xcore.stopLineStr + pub_returnCode +

      '<div class="t c">'+pub_returnCode+
      '<img src="'+xcore.name[dindex]+'" alt="'+windows1252__xmlFilterLine(dtitle)+'" style="aspect-ratio:'+pub__single(xcore.h[dindex]/frcmin32(xcore.w[dindex],1))+';max-width:100%;" />'+pub_returnCode+
      '</div>'+pub_returnCode+

      pub_returnCode+
      '</body>'+pub_returnCode+

      pub_returnCode+
      '</html>'+pub_returnCode;

      //add file -> return document slot instead of image slot
      if pub__addfile( xcore ,pub_html ,utf8__fromWin1252StrB( d.text ) ,'' ,dindex ) then//utf-8
         begin

         //heading for contents.html
         xcore.headingRaw[dindex]         :=dtitle;

         end;

      end;

   end

//image as cover
else if (dimageStorageStyle=pub_isImageCover) then
   begin

   //make jpg
   if dneed and pub__convertImage( xcore ,simageStream ,d ,true ,etmp ) and pub__enforceImageLimits( xcore ,d ,dw ,dh ) and xaddfile( xcore ,pub_coverjpg ,d.text ,simageStream.text ,dindex ,dw ,dh ) then
      begin

      //init
      result                    :=true;//successful

      //titlepage.xhtml
      d.text:=
      '<?xml version="1.0" encoding="'+pub_utf8+'"?>'+pub_returnCode+
      '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">'+pub_returnCode+
      '<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" xmlns:xml="http://www.w3.org/XML/1998/namespace">'+pub_returnCode+

      pub_returnCode+
      '<head>'+pub_returnCode+

      pub_returnCode+
      '<meta http-equiv="Content-Type" content="text/html; charset='+pub_utf8+'" />'+pub_returnCode+
      '<title>Title Page</title>'+pub_returnCode+

      pub_returnCode+
      '<style type="text/css" title="override_css">'+
      '@page {padding:0;margin:0;} '+
      'body {text-align:center;padding:0;margin:0;} '+
      'div {margin:0;padding:0;}'+
      '</style>'+pub_returnCode+

      pub_returnCode+
      '</head>'+pub_returnCode+

      pub_returnCode+
      '<body>'+pub_returnCode+

      pub_returnCode+
      '<div class="t c">'+pub_returnCode+
      '<img src="'+xcore.name[dindex]+'" alt="Cover Image" style="height:100%;" />'+pub_returnCode+
      '</div>'+pub_returnCode+

      pub_returnCode+
      '</body>'+pub_returnCode+

      pub_returnCode+
      '</html>'+pub_returnCode;

      //add file -> return document slot instead of image slot
      pub__addfile( xcore ,pub_titlepage ,utf8__fromWin1252StrB( d.text ) ,'' ,dindex );//utf-8

      xcore.slot_titlepageXhtml :=dindex;

      end;

   end;

except;end;

//free
if (d<>nil) then faststr__free(@d);

end;

function pub__addContents(var xcore:tpubinfo):boolean;
var
   b                            :tstr8;
   p                            :longint32;

   procedure ladd(const v:string);
   begin

   b.sadd( v + pub_returnCode );

   end;

   procedure hadd(const findex:longint32);
   begin

   if (findex>=0) and (findex<xcore.count) and ( (xcore.style[findex]=pub_html) or (xcore.style[findex]=pub_xhtml) ) then
      begin

      ladd( xcore.startBeginContentsLineStr + ' id="section'+pub__digPad(xcore.nval[findex])+'"><a href="section'+pub__digPad(xcore.nval[findex])+'.'+xcore.format[findex]+'">'+windows1252__xmlFilterLine(xcore.headingRaw[findex])+'</a></p>');

      end;

   end;

begin

//defaults
b                               :=nil;

try

//init
b                               :=faststr__new8;

//get
ladd('<?xml version="1.0" encoding="'+pub_utf8+'"?>');
ladd('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">');
ladd('<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" xmlns:xml="http://www.w3.org/XML/1998/namespace">');

ladd('');
ladd('<head>');

ladd('');
ladd('<meta http-equiv="content-type" content="text/html; charset='+pub_utf8+'"/>');
ladd('<meta content="http://www.w3.org/1999/xhtml; charset='+pub_utf8+'" http-equiv="content-type"/>');
ladd('<title>'+windows1252__xmlFilterLine(pub__title(xcore))+'</title>');
ladd('<link href="css/stylesheet.css" type="text/css" rel="stylesheet"/>');
ladd('<meta name="generator" content="'+windows1252__xmlFilterLine(pub__generator)+'"/>');
ladd('<meta name="author" content="'+windows1252__xmlFilterLine(pub__author(xcore))+'"/>');
ladd('<meta name="created" content="'+windows1252__xmlFilterLine(pub__releasedate(xcore))+'"/>');
ladd('<meta name="changed" content="'+windows1252__xmlFilterLine(pub__releasedate(xcore))+'"/>');
ladd('<meta name="info_1" content=""/>');
ladd('<meta name="info_2" content=""/>');
ladd('<meta name="info_3" content=""/>');
ladd('<meta name="info_4" content=""/>');

ladd('');
ladd(pub_pageStyleCode);

ladd('');
ladd('</head>');

ladd('');
ladd('<body>');

ladd('');
ladd( xcore.startLineNormalHeaderStr + 'Contents' + xcore.stopLineStr );

//.cover
ladd( xcore.startBeginContentsLineStr + ' id="titlepage"><a href="titlepage.xhtml">Cover</a></p>');

//.chapters/documents
for p:=0 to pred(xcore.count) do hadd(p);

ladd('');
ladd('</body>');

ladd('');
ladd('</html>');

//add files
pub__addfile( xcore ,pub_contentshtml ,utf8__fromWin1252StrB( b.text ) ,'' ,xcore.slot_contentsHtml );//utf-8

except;end;

//free
if (b<>nil) then faststr__free(@b);

end;

function pub__addStylesheet(var xcore:tpubinfo):boolean;
var
   b                            :tstr8;

   procedure ladd(const v:string);
   begin

   b.sadd( v + pub_returnCode );

   end;

begin

//defaults
b                               :=nil;

try

//init
b                               :=faststr__new8;

ladd('@namespace h "http://www.w3.org/1999/xhtml";');
ladd('p ,span {');
ladd('font-style:normal;');
ladd('font-weight:normal;');
ladd('text-indent:0;');
ladd('margin:0;');
ladd('padding:0;');
ladd('}');
ladd('');

ladd('p {');
ladd('display:block;');
ladd('}');
ladd('');

ladd('span {');
ladd('display:inline;');
ladd('}');
ladd('');

ladd('img {');
ladd('border:0;');
ladd('padding:0.1em;');
ladd('vertical-align:text-bottom;');
ladd('}');
ladd('');

ladd('.l {text-align:left !important;}'    );
ladd('.c {text-align:center !important;}'  );
ladd('.r {text-align:right !important;}'   );
ladd('.j {text-align:justify !important;text-justify:inter-word !important;}' );

ladd('.i {text-indent:'+pub__single(low__posn(xcore.indentChars)/2)+'em !important;}'  );
ladd('.i2 {text-indent:2em !important;}'   );//fixed at 2em -> for contents

ladd('.bb {font-weight:bold !important;}'                              );
ladd('.ii {font-style:italic !important;}'                             );
ladd('.uu {text-decoration:underline !important;}'                     );
ladd('.ss {text-decoration:line-through !important;}'                  );
ladd('.us {text-decoration:underline line-through !important;}'        );
ladd('.vv {padding-top:'+intstr32(xcore.headerVPad)+'% !important;padding-bottom:'+intstr32(xcore.textVPad)+'% !important;}' );//vertical padding

ladd('.m0 {margin:0 !important;}'                                      );
ladd('.vm025 {margin:0.25em 0 !important;}'                            );
ladd('.vm050 {margin:0.50em 0 !important;}'                            );
ladd('.vm100 {margin:1.00em 0 !important;}'                            );
ladd('.vv025 {padding-top:0.25em 0 !important;}'                       );
ladd('.vv050 {padding-top:0.50em 0 !important;}'                       );
ladd('.vv100 {padding-top:1.00em 0 !important;}'                       );
ladd('.pad0 {padding:0 !important;}'                                   );
ladd('');

ladd('.h {');
ladd('font-size:'+pub__single(xcore.headerSize/100)+'em;');
ladd('}');
ladd('');

ladd('.t, .s {');
ladd(xcore.lineHeightStr);
ladd('font-size:'+pub__single(xcore.textSize/100)+'em;');
ladd('}');
ladd('');

ladd('a, a:link {');
ladd(xcore.lineHeightStr);
ladd('font-size:1em;');
ladd('text-decoration:none;');
ladd('cursor:pointer;');
ladd('}');
ladd('');

ladd('a:hover {');
ladd('font-size:1em;');
ladd('text-decoration:underline;');
ladd('cursor:pointer;');
ladd('}');
ladd('');

ladd('a[href] {');
ladd('text-decoration:none;');
ladd('cursor:pointer;');
ladd('}');
ladd('');

ladd('.abovechar {');
ladd('font-size:'+pub__single( 2.0 * (xcore.textSize/100) )+'em;');
ladd('margin-right:0.02em;');
ladd('}');
ladd('');

ladd('.dropchar {');
ladd('float:left;');
ladd('font-size:'+pub__single( 2.5 * (xcore.textSize/100) * (xcore.lineheight/100) )+'em;');
ladd('line-height:' +pub__single( 0.6 * (xcore.lineheight/100) ) + 'em;');
ladd('margin:0;');
ladd('margin-right:0.10em;');
ladd('margin-top:0.05em;');
ladd('padding:0;');
ladd('vertical-align:top;');
ladd('}');
ladd('');

ladd('.smallcaps {');
ladd('font-size:'+pub__single(0.7)+'em;');
ladd('font-weight:bolder;');
ladd('}');
ladd('');

//add file
pub__addfile( xcore ,pub_styleSheetcss ,utf8__fromWin1252StrB( b.text ) ,'' ,xcore.slot_stylesheetcss );//utf-8

except;end;

//free
if (b<>nil) then faststr__free(@b);

end;

function crc32__nonzero(const x:string):longint32;//15oct2026
var
   a                            :tstr8;

begin

//defaults
result                          :=0;
a                               :=nil;

try

//init
a                               :=faststr__new8;
a.text                          :=x;

//get
result                          :=low__crc32nonzero(a);

except;end;

//free
faststr__free( @a );

end;

function pub__addContentopf(var xcore:tpubinfo):boolean;
var
   b                            :tstr8;
   p                            :longint32;

   function xcopyright:string;
   begin

   result                       :=app__info('copyright');

   strdel1(result,1,1);

   result                       :='(c)'+result;

   end;

   procedure ladd(const v:string);
   begin

   b.sadd( v + pub_returnCode );

   end;

begin

//defaults
b                               :=nil;

try

//init
b                               :=faststr__new8;


//package.start ----------------------------------------------------------------

ladd('<?xml version="1.0" encoding="'+pub_utf8+'"?>');
ladd('<package xmlns="http://www.idpf.org/2007/opf" version="2.0" unique-identifier="uuid_id">');


//metadata ---------------------------------------------------------------------

ladd('');
ladd('<metadata xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:opf="http://www.idpf.org/2007/opf">');
ladd('<dc:identifier id="uuid_id" opf:scheme="uuid">'+xcore.uuid+'</dc:identifier>');
ladd('<dc:title>'+windows1252__xmlFilterLine(pub__title(xcore))+'</dc:title>');
ladd('<dc:language>en-US</dc:language>');
ladd('<dc:date>'+pub__releasedate(xcore)+'</dc:date>');
ladd('<dc:date opf:event="publication">'+pub__releasedate(xcore)+'</dc:date>');
ladd('<dc:creator opf:role="aut" opf:file-as="'+windows1252__xmlFilterLine(pub__authorR(xcore))+'">'+windows1252__xmlFilterLine(pub__author(xcore))+'</dc:creator>');
ladd('<dc:publisher>'+windows1252__xmlFilterLine(xcore.publisher)+'</dc:publisher>');//18oct2026
ladd('<meta name="cover" content="cover-image"/>');
ladd('<dc:subject>'+windows1252__xmlFilterLine(xcore.subject)+'</dc:subject>');
ladd('<dc:description>'+windows1252__xmlFilterLine(xcore.des)+'</dc:description>');
ladd('<dc:rights>'+windows1252__xmlFilterLine(xcore.rights)+'</dc:rights>');

if (xcore.isbn<>'') then
   begin

   ladd('<dc:identifier id="isbn" opf:scheme="isbn">'+windows1252__xmlFilterLine(xcore.isbn)+'</dc:identifier>');

   end;

ladd('<dc:contributor opf:role="bkp">'+windows1252__xmlFilterLine(pub__generator)+'</dc:contributor>');
ladd('<meta name="generator" content="'+windows1252__xmlFilterLine(pub__generator)+'" />');
ladd('</metadata>');


//manifest ---------------------------------------------------------------------

ladd('');
ladd('<manifest>');
ladd('<item href="images/cover.jpg" id="cover-image" media-type="image/jpeg" />');
ladd('<item href="css/stylesheet.css" id="css" media-type="text/css" />');
ladd('<item href="titlepage.xhtml" id="titlepage" media-type="application/xhtml+xml" />');
ladd('<item href="contents.html" id="contents" media-type="application/xhtml+xml" />');
ladd('<item href="toc.ncx" id="ncx" media-type="application/x-dtbncx+xml" />');

//.documents
for p:=0 to pred(xcore.count) do
begin

if (xcore.style[p]=pub_html) or (xcore.style[p]=pub_xhtml) then
   begin

   ladd('<item href="'+xcore.name[p]+'" id="section'+pub__digPad(xcore.nval[p])+'" media-type="application/xhtml+xml" />');

   end;

end;//p

//.images
for p:=0 to pred(xcore.count) do
begin

if (xcore.style[p]=pub_image) then
   begin

   ladd('<item href="'+xcore.name[p]+'" id="image'+pub__digPad(xcore.nval[p])+'" media-type="'+net__mimefind(io__readfileext(xcore.name[p],false))+'" />');

   end;

end;//p

ladd('</manifest>');


//spine ------------------------------------------------------------------------

ladd('');
ladd('<spine toc="ncx">');
ladd('<itemref idref="titlepage" />');
ladd('<itemref idref="contents" />');

for p:=0 to pred(xcore.count) do
begin

if (xcore.style[p]=pub_html) or (xcore.style[p]=pub_xhtml) then
   begin

   ladd('<itemref idref="section'+pub__digPad(xcore.nval[p])+'" />');

   end;

end;//p

ladd('</spine>');


//guide ------------------------------------------------------------------------

ladd('');
ladd('<guide>');

ladd('<reference type="cover" title="Cover" href="titlepage.xhtml" />');//cover page
ladd('<reference type="toc" title="Contents" href="contents.html" />');//table of contents

case (xcore.firstChapterIndex>=0) of
true:ladd('<reference type="text" title="'+windows1252__xmlFilterLine(xcore.headingRaw[xcore.firstChapterIndex])+'" href="'+xcore.name[xcore.firstChapterIndex]+'" />');//first chapter
else ladd('<reference type="text" title="Contents" href="contents.html" />');//contents
end;//case

ladd('</guide>');


//package.stop -----------------------------------------------------------------

ladd('');
ladd('</package>');

//.add file
pub__addfile( xcore ,pub_contentopf ,utf8__fromWin1252StrB( b.text ) ,'' ,xcore.slot_contentsOpf );//utf-8

except;end;

//free
if (b<>nil) then faststr__free(@b);

end;

function pub__addTOCncx(var xcore:tpubinfo):boolean;
var
   b                            :tstr8;
   p                            :longint32;
   dcount                       :longint32;

   procedure ladd(const v:string);
   begin

   b.sadd( v + pub_returnCode );

   end;

   function dcountstr:string;
   begin

   inc(dcount);

   result                       :=intstr32(dcount);

   end;

begin

//defaults
b                               :=nil;

try

//init
b                               :=faststr__new8;
dcount                          :=0;


//start ------------------------------------------------------------------------

ladd('<?xml version="1.0" encoding="'+pub_utf8+'"?>');
ladd('<!DOCTYPE ncx PUBLIC "-//NISO//DTD ncx 2005-1//EN" "http://www.daisy.org/z3986/2005/ncx-2005-1.dtd">');
ladd('<ncx xmlns="http://www.daisy.org/z3986/2005/ncx/" version="2005-1">');


//head -------------------------------------------------------------------------
ladd('');
ladd('<head>');
ladd('<meta name="dtb:uid" content="'+xcore.uuid+'" />');
ladd('<meta name="dtb:depth" content="1" />');
ladd('<meta name="dtb:generator" content="'+windows1252__xmlFilterLine(pub__generator)+'" />');
ladd('<meta name="dtb:totalPageCount" content="0" />');
ladd('<meta name="dtb:maxPageNumber" content="0" />');
ladd('</head>');


//doc title --------------------------------------------------------------------

ladd('');
ladd('<docTitle><text>'+windows1252__xmlFilterLine(pub__title(xcore))+'</text></docTitle>');
ladd('<docAuthor><text>'+windows1252__xmlFilterLine(pub__author(xcore))+'</text></docAuthor>');


//nav map ----------------------------------------------------------------------

ladd('');
ladd('<navMap>');
ladd('<navPoint playOrder="'+dcountStr+'" id="titlepage"><navLabel><text>Cover</text></navLabel><content src="titlepage.xhtml" /></navPoint>');
ladd('<navPoint playOrder="'+dcountStr+'" id="contents"><navLabel><text>Contents</text></navLabel><content src="contents.html" /></navPoint>');

for p:=0 to pred(xcore.count) do
begin

if (xcore.style[p]=pub_html) or (xcore.style[p]=pub_xhtml) then
   begin

   ladd('<navPoint playOrder="'+dcountStr+'" id="section'+pub__digPad(xcore.nval[p])+'"><navLabel><text>'+windows1252__xmlFilterLine(xcore.headingRaw[p])+'</text></navLabel><content src="'+xcore.name[p]+'" /></navPoint>');

   end;

end;//p

ladd('</navMap>');


//finish -----------------------------------------------------------------------

ladd('');
ladd('</ncx>');

//.add file
pub__addfile( xcore ,pub_TOCncx ,utf8__fromWin1252StrB( b.text ) ,'' ,xcore.slot_tocNcx );//utf-8

except;end;

//free
if (b<>nil) then faststr__free(@b);

end;

function pub__containerxml:string;
begin

result:=

'<?xml version="1.0" encoding="'+pub_utf8+'"?>'+pub_returnCode+
'<container xmlns="urn:oasis:names:tc:opendocument:xmlns:container" version="1.0">'+pub_returnCode+
'<rootfiles>'+pub_returnCode+
'<rootfile full-path="OEBPS/content.opf" media-type="application/oebps-package+xml"/>'+pub_returnCode+
'</rootfiles>'+pub_returnCode+
'</container>'+pub_returnCode;

end;

function pub__mimetype:string;
begin

result:='application/epub+zip';

end;

function pub__generator:string;
begin

result:=app__info('name') + ' v'+app__info('ver') + #32#169#32 + low__yearstr(2026) + #32 + app__info('author.name');

end;

function pub__uuid(const xcore:tpubinfo):string;//20oct2026
var//8-4-4-4-12 hex character structure (total of 36 characters including hyphens):

   v        :string;

begin

v           :=int4__hex8(crc32__nonzero(strlow(xcore.fname+'-'+xcore.lname)));

result      :=strlow(//must be lowercase

            //.8 chars
            int4__hex8(crc32__nonzero(strlow(xcore.title)))+//crc32 of book title
            '-'+

            //.4 chars
            strcopy1(v,1,4)+//author name part1 (1..4)
            '-'+
            
            //.4 chars -> leading 4 signifies "random uuid"
            '4e20'+//4 is required and "e20" is our "EPUB v2.0 specification"
            '-'+

            //.4 chars
            'a'+strcopy1(v,5,3)+//8,9,a or b is required and 3c's -> author name part2 (5..7)
            '-'+
            
            //.12 chars
            low__digpad11(xcore.year,4)+//year4
            low__digpad11(xcore.month,2)+//month2
            low__digpad11(xcore.day,2)+//day2
            low__digpad11(restrict32(xcore.buildNumber),4)+//4c

            '');

end;

function pub__title(const xcore:tpubinfo):string;
begin

result:=pub__asTitle( xcore.title ,'' );

end;

function pub__asTitle(const xlabel,xdef:string):string;//20oct2026
begin

//def
result      :=strdefb( stripwhitespace_lt(xlabel) ,stripwhitespace_lt(strdefb(xdef,'Untitled')) );

//first letter upper case
if (result<>'') then
   begin

   result   :=strup( strcopy1(result,1,1) ) + strcopy1(result,2,low__len32(result));

   end;

end;

function pub__author(const xcore:tpubinfo):string;
begin

result:=xcore.fname+#32+xcore.lname;

end;

function pub__authorR(const xcore:tpubinfo):string;
begin

result:=xcore.lname+', '+xcore.fname;

end;

function pub__releaseDate(const xcore:tpubinfo):string;
begin

result:=intstr32(xcore.year)+'-'+intstr32(xcore.month)+'-'+intstr32(xcore.day)+'T00:00:01Z';

end;

function pub__asEbookFilename(const n:string):string;
begin

if (n<>'') then result  :=io__remlastext( n ) + '.epub'
else            result  :='';

end;

function pub__buildOptionValue(const xvalue:string;const xmin,xmax,xdef:longint32):longint32;//17oct2026
var
   v                                   :string;

begin

//filter
v                                      :=stripwhitespace_lt( xvalue );
v                                      :=low__remcharb( v , ',' );//"1,000" -> "1000"

//get
if      (v='')                                               then result :=xdef
else if (strint32(v)<xmin)                                   then result :=xdef
else if (k64(strint32(v))<>v) and (intstr32(strint32(v))<>v) then result :=xdef
else                                                              result :=frcrange32( strint32(v) ,xmin ,xmax);

end;

function pub__buildOptionBool(const xvalue:string;const xdef:boolean):boolean;//17oct2026
begin

result                                 :=( pub__buildOptionValue( xvalue ,0 ,1 ,insint(1,xdef) ) <> 0 );

end;

function pub__imageIsJpeg(const sformat:string):boolean;
begin

result:=
 strmatch(sformat,'jpg')  or
 strmatch(sformat,'jpeg') or
 strmatch(sformat,'jif');

end;

function pub__imageFormatSupported(const sformat:string):boolean;
begin

result:=
 pub__imageIsJpeg(sformat) or
 strmatch(sformat,'png')   or
 strmatch(sformat,'gif');

end;

function pub__imageMustConvert(const sformat:string;const ximageConversion:longint32):boolean;
begin

if not  pub__imageFormatSupported(sformat)                        then result:=true
else if (ximageConversion>=1) and (not pub__imageIsJpeg(sformat)) then result:=true
else if (ximageConversion>=2)                                     then result:=true
else                                                                   result:=false;

end;

function pub__convertImage(const xcore:tpubinfo;const s,d:tstr8;const ximageIsCover:boolean;var e:string):boolean;
var
   a                         :tbasicimage;
   a2                        :tbasicimage;
   etmp                      :string;
   dformat                   :string;

begin

//defaults
result                       :=false;
e                            :=gecTaskfailed;
a                            :=nil;
a2                           :=nil;

//checkers
if not str__ok(@s) then exit;
if not str__ok(@d) then exit;

try

//clear
d.clear;

//cover image
if ximageIsCover then
   begin

   //init
   a                            := misimg32(1,1);
   a2                           := misimg32( xcore.coverWidth ,xcore.coverHeight );

   //get -> size image to cover dimensions -> save as jpeg image
   result                       := mis__fromdata( a ,@s ,etmp ) and mis__onecell( a )                    and
                                   mis__copyfast( maxarea ,misarea(a) ,0 ,0 ,misw(a2) ,mish(a2) ,a ,a2 ) and
                                   mis__todata2 ( a2 ,@d ,'jpg' ,xcore.coverQuality ,etmp );

   end

//normal image -> retain image OR convert to jpeg
else begin

   //.conversion required
   if pub__imageMustConvert( io__anyformatb( @s ) ,xcore.imageConversion ) then
      begin

      //init
      a                         := misimg32(1,1);

      //get -> convert image and save
      if mis__fromdata( a ,@s ,etmp ) and mis__onecell( a ) then
         begin

         //transparent image -> png, else jpg
         if (xcore.imageConversion<=1) and mask__hasTransparency32( a ) then dformat:='png'
         else                                                                dformat:='jpg';

         result                 :=mis__todata2 ( a ,@d ,dformat ,xcore.imageQuality ,etmp );

         end;

      end

   //.image is already in a supported format -> no conversion required
   else begin

      result                    :=d.addfast32( s );

      end;


   end;

except;end;

//free
if (a <>nil) then freeobj(@a );
if (a2<>nil) then freeobj(@a2);

end;

function pub__digPad(const x:longint32):string;
begin

result      :=low__digpad11(x,4);

end;

procedure pub__makeStrs(var xcore:tpubinfo;const xformatDocument:boolean);
var
   p                  :longint32;

   function xheaderAlign:string;
   begin

   case xcore.headerAlign of

   0    :result:='l ';
   1    :result:='c ';
   2    :result:='r ';
   else  result:='c';

   end;//case

   end;

   function xtextLeftAlign:string;
   begin

   if xformatDocument and (xcore.textJustify>=1) then result:=' j'//justify text
   else                                               result:=' l';//left align text

   end;

begin

with xcore do
begin

//.dformatDocument
dformatDocument                 :=xformatDocument;

//.indentChars
case (indentChars>=0) of

true:indentFirst:=0 //NO - don't indent first paragraph of chapter
else indentFirst:=1;//YES - indent every paragraph regardless

end;//case

//.strs
headerSizeStr                   :='font-size:'    + pub__single(headersize/100)           + 'em;' ;
textSizeStr                     :='font-size:'    + pub__single(textsize  /100)           + 'em;' ;
lineHeightStr                   :='line-height:'  + pub__single(lineheight/100)           + 'em;' ;

case imageConversion of
4   :coverQuality               :=ia_fairquality;
3   :coverQuality               :=ia_fairquality;
2   :coverQuality               :=ia_goodquality;
else coverQuality               :=ia_highquality;
end;//case

case imageConversion of//quality is slightly higher compared to cover
4   :imageQuality               :=ia_fairquality;
3   :imageQuality               :=ia_goodquality;
2   :imageQuality               :=ia_highquality;
else imageQuality               :=ia_highquality;
end;//case

//.other
startLineNormalHeaderStr        :='<p class="h c vm100">';
startLineChapterHeaderStr       :='<p class="h ' + xheaderAlign + 'vm100 vv">';

case dformatDocument of

true:startLineHeaderStr         :=startLineChapterHeaderStr;
else startLineHeaderStr         :=startLineNormalHeaderStr;

end;//case

startLineIndentLStr             :='<p class="t'+xtextLeftAlign+' i">';
startLineIndentCStr             :='<p class="t c">';//removed "i"
startLineIndentRStr             :='<p class="t r">';//removed "i"
startLineLStr                   :='<p class="t'+xtextLeftAlign+'">';
startLineCStr                   :='<p class="t c">';
startLineRStr                   :='<p class="t r">';
startBeginContentsLineStr       :='<p class="t i2 vm025 vv025"';
stopLineStr                     :='</p>';

case sceneSep of

3   :sceneSepStr                   :='<p class="s c vm050">' + '&#9830; &#160; &#9830; &#160; &#9830;' + stopLineStr;
else sceneSepStr                   :='<p class="s c vm050">* * *' + stopLineStr;

end;//case

case dformatDocument of

true:begin

   dindentChars                 :=low__posn( indentChars );
   dindentFirst                 :=indentFirst;
   ddropCaps                    :=dropCaps;
   dblankLine                   :=blankLine;

   end;

else begin

   dindentChars                 :=0;//none
   dindentFirst                 :=0;//none
   ddropCaps                    :=0;//none
   dblankLine                   :=1;//essay mode

   end;

end;//case

//.dropCaps
case ddropCaps of

3   :ddropWordLimit             :=1;
4   :ddropWordLimit             :=2;
5   :ddropWordLimit             :=3;
6   :ddropWordLimit             :=4;
7   :ddropWordLimit             :=5;
else ddropWordLimit             :=1;

end;//case

//.blankLine
blankLineStr                    :='';

for p:=1 to dblankLine do
begin

blankLineStr                    :=blankLineStr + insstr( pub_returnCode ,blankLineStr<>'' ) + '<p class="t c">&#160;</p>' ;

end;//p


end;//with

end;

function pub__single(const x:double):string;
begin

result      :=floattostrex( x ,2 );

end;

function pub__setFirstError(var xcore:tpubinfo;const xnewErrorMsg:string):boolean;
begin

result                :=true;

if (xcore.firstError='') then
   begin

   xcore.firstError   :=xnewErrorMsg;

   end;

end;

function pub__helpText:string;

   procedure a(const v:string);
   begin

   result             :=result + v + #10;

   end;

   procedure mh(const v:string);
   begin

   if (result<>'') then a( '' );
   a( '**** '+v + ' ****' );

   end;

   procedure h(const v:string);
   begin

   if (result<>'') then a( '' );
   a( '-- '+v + ' --' );

   end;

   function ximgExts:string;
   var
      p     :longint32;
      v     :string;
      bol1  :boolean;
      
   begin

   //defaults
   result   :='';

   for p:=0 to max32 do
   begin

   if io__imageExt( p ,v ,bol1 ) then result:=result+insstr(', ',result<>'')+v
   else                          break;

   end;//p

   end;

begin

//defaults
result                :='';

//get

mh('Book and Author Information');
a('');
a('Book.Title: Name of your book');
a('Author.First.Name: Your first name');
a('Author.Last.Name: Your last name');
a('Publisher: Name of publisher or your website (optional)');
a('Rights: Copyright line (optional)');
a('ISBN: Your book''s ISBN number (optional)');
a('Des: Short description of your book (optional)');
a('Release.Year: 4 digit year');
a('Release.Month: A number in range 1-12');
a('Release.Day: A number in range 1-31');

a('');
mh('Build Options');

h('Header.VPad%');
a('Vertical padding in % to drop chapter heading from the top of the page.');
a('Range 0..80, default='+intstr32(pub_headerVPad_def));

h('Header.Size%');
a('Size of header text in %.');
a('Range 10..1200, default='+intstr32(pub_headerSize_def));

h('Header.Align');
a('Align chapter heading.');
a('Range 0..2, default='+intstr32(pub_headerAlign_def));
a('');
a('0 = Left');
a('1 = Center');
a('2 = Right');

h('Text.VPad%');
a('Vertical padding in % to drop the text below the chapter heading.');
a('Range 0..80, default='+intstr32(pub_textVPad_def));

h('Text.Size%');
a('Size of text in %.');
a('Range 10..1200, default='+intstr32(pub_textSize_def));

h('Text.Justify');
a('Justify text. Applies to left-aligned text.');
a('Range 0..1, default='+intstr32(pub_textJustify_def));
a('');
a('0 = Off');
a('1 = Justify text');

h('Line.Height%');
a('Line height (spacing) for header and text in %');
a('Range 80..500, default='+intstr32(pub_lineHeight_def));
a('');
a('100 = 1.0 (no spacing)');
a('120 = 1.2 line spacing');
a('150 = 1.5 line spacing');
a('200 = 2.0 line spacing');

h('Drop.Caps');
a('Enhance first line of a chapter.');
a('Range 0..7, default='+intstr32(pub_dropCaps_def));
a('');
a('0 = Off');
a('1 = Single large letter on same line');
a('2 = Single large letter dropped down from line');
a('3 = First 1 word in small caps');
a('4 = First 2 words in small caps');
a('5 = First 3 words in small caps');
a('6 = First 4 words in small caps');
a('7 = First 5 words in small caps');

h('Indent.Chars');
a('Number of spaces to indent the first line of each paragraph.');
a('Range -20..20, default='+intstr32(pub_indentChars_def));
a('');
a('0 = Off');
a('1..20 = Indent all paragraphs except the first');
a('-1..-20 = Indent all paragraphs');

h('Blank.Line');
a('Insert blank lines between paragraphs.');
a('Range 0..2, default='+intstr32(pub_blankLine_def));
a('');
a('0 = Off');
a('1 = One blank line');
a('2 = Two blank lines');

h('Format.Up');
a('Convert plain text values into symbolic versions.');
a('Range 0..1, default='+intstr32(pub_formatUp_def));
a('');
a('0 = Off');
a('1 = On');
a('');
a('When on, converts the following text values:');
a('(c) = copyright');
a('(r) = registered');
a('(tm) = trademark');
a('1/4 = quarter');
a('1/2 = half');
a('3/4 = three quarters');
a('^1 = power of 1');
a('^2 = power of 2');
a('^3 = power of 3');
a('+/- = plus or minus');
a('... = ellipsis');
a('. . . = ellipsis');
a('-- = em dash');

h('Scene.Sep');
a('Standardise scene separators and convert slight variations into one consistent version.');
a('Range 0..3, default='+intstr32(pub_sceneSep_def));
a('');
a('0 = Off');
a('1 = One hash on a line -> make basic');
a('2 = Three asterisks on a line -> make basic');
a('3 = (1) or (2) above -> make enhanced');
a('');
a('A basic scene separator is 3 equally spaced asterisks centered on a line, and an enhanced scene separator is 3 diamonds centered on a line.');

h('Quotes.Single');
a('Format single quotes.');
a('Range 0..2, default='+intstr32(pub_quotesSingle_def));
a('');
a('0 = Off');
a('1 = Convert curly to straight');
a('2 = Auto-convert to curly 6 and 9');
a('');
a('Note: Option 2 may fail on abreviations such as ''cause. Use with caution.');

h('Quotes.Double');
a('Format double quotes.');
a('Range 0..2, default='+intstr32(pub_quotesDouble_def));
a('');
a('0 = Off');
a('1 = Convert curly to straight');
a('2 = Auto-convert to curly 66 and 99');

h('Image.Conversion');
a('Convert images to png/jpeg format for maximum compatiblity with e-book readers.');
a('');
a('Duplicate images are automatically filtered out by binary data stream matching, leaving a single shared copy for all documents, across all image conversion modes, even mode 0.');
a('Range 0..4, default='+intstr32(pub_imageConversion_def));
a('');
a('0 = Leave images as is, only convert to png/jpeg if not jpg, jif, jpeg, png, or gif.');
a('1 = Convert transparent images to png and solid images to jpeg at high quality');
a('2 = Convert all images to jpeg at high quality');
a('3 = Convert all images to jpeg at good quality');
a('4 = Convert all images to jpeg at fair quality');

a('');
mh('Document Files');
a('');
a('A list of files in bwd, bwp, rtf, or txt format to include as sections/chapters for your e-book. One file name per line.');
a('');
a('May also be an image file of '+ximgExts+'.');
a('');
a('If an image is specified then its file name will be used for the heading, and also for the link name in the contents section.');
a('');
a('Files are processed and listed within the e-book in first to last (top to bottom) order.');
a('');
a('Each file can be a simple name - e.g. mydocument.txt - which assumes it resides in the current folder, or a full path + name, if the file resides '+
  'elsewhere on your computer - e.g. f:\mydocuments\current\mydocument.rtf');

h('Cover Image');
a(
  'The cover image for your e-book is sourced from the first (top most) file name in the list. '+
  'It can be a document containing an image (first image is used, rest of document is discarded), or an image file. '+
  'The cover image will be resized to '+k64(pub_coverHeight_def)+'h x '+k64(pub_coverWidth_def)+'w at a '+pub__single(pub_coverHeight_def/frcmin32(pub_coverWidth_def,1))+':1 ratio and converted to a jpeg.'
  );

h('Chapter One');
a('You can mark your chapter one by including a greater than symbol ">" before the document file name (in the Document Files list).');
a('');
a('This corresponds to the Kindle''s "Go to Beginning" navigation option, or the Start Reading Location (SRL).');
a('');
a('Example 1:');
a('file: cover.bwp');
a('file: >f:\mydocuments\chapter1.rtf');
a('file: f:\mydocuments\chapter2.rtf');
a('file: chapter3.rtf');
a('file: chapter4.rtf');
a('file: *backmatter.txt');
a('');
a('Example 2:');
a('file: myBookCover.bmp');
a('file: intro.txt');
a('file: >f:\mydocuments\chapter1.rtf');
a('file: f:\mydocuments\chapter2.rtf');
a('file: chapter3.rtf');
a('file: chapter4.rtf');
a('file: *backmatter.txt');

h('Plain Formatting');
a('For documents like copyright, about, backmatter, etc, chapter-based formatting can be switched off by including an asterisk before the file name.');
a('');
a('A plain formatted document has a centered heading, no indentation, no drop caps, no vertical heading/text padding, no justification, and a single blank line between paragraphs.');

a('');
a('Example 1:');
a('file: cover.bwp');
a('file: *copyright.bwd');
a('file: chapter1.rtf');
a('file: chapter2.rtf');
a('file: chapter3.rtf');
a('file: chapter4.rtf');
a('file: *backmatter.txt');
a('');
a('Both the copyright.bwd and backmatter.txt documents are processed using plain formatting.');
a('');
a('Example 2:');
a('file: cover.bwp');
a('file: *copyright.bwd');
a('file: >*chapter1.rtf');
a('file: chapter2.rtf');
a('file: chapter3.rtf');
a('file: chapter4.rtf');
a('file: *backmatter.txt');
a('');
a('The files copyright.bwd, chapter1.rtf, and backmatter.txt are processed using plain formatting, and in addition, chapter1.rtf is marked as chapter one/Start Reading Location (SRL).');

h('Hyperlinks');
a('Urls beginning with:');
a('"https://"');
a('"http://"');
a('"ftps://"');
a('"ftp://"');
a('excluding the double quotes are automatically embedded into the page with their leading protocols (e.g. https://) visually removed. Email links in the format "mailto:(email address)" are also embedded.');
a('');
a('Examples:');
a('https://www.blaizenterprises.com');
a('-> www.blaizenterprises.com');
a('');
a('http://www.blaizenterprises.com');
a('-> www.blaizenterprises.com');
a('');
a('mailto:contact@blaizenterprises.com');
a('-> contact@blaizenterprises.com');


end;

function pub__copy(const s:tbasicbwp;sbuildFolder:string):boolean;
label
   skipend;

var
   b                  :tstr8;
   dline              :tstr8;
   d                  :tstr8;
   dpos               :longint32;
   dformatDocument    :boolean;
   dchapterOne        :boolean;
   f                  :string;

begin

//defaults
result                :=false;
b                     :=nil;
d                     :=nil;
dline                 :=nil;
sbuildFolder          :=io__asfolderNIL( sbuildFolder );

//check
if (s=nil) or (sbuildFolder='') then exit;

try

//init
b                     :=faststr__new8;
d                     :=faststr__new8;
dline                 :=faststr__new8;
dpos                  :=0;

//get
if not s.iogettxt(b) then goto skipend;

//enforce full filenames for Chapter Files during copy process

while str__nextline0( @b ,@dline ,dpos ) do
begin

if pub__isDocumentFile(dline.text) then
   begin

   //filename
   f                  :=pub__extractDocumentFile( dline.text ,dformatDocument ,dchapterOne );

   //"c:\folder\abc.txt" - 15oct2026
   if (strcopy1(f,2,1)=':') then
      begin

      //convert "portable" filename to "global"
      if (strcopy1(f,1,1)='?') then
         begin

         f            :=io__readportablefilename( f );

         end;

      end

   //make "global" filename
   else if not low__havechar(f,':') then
      begin

      f               :=sbuildFolder + io__extractfilename(f);

      end;

   d.sadd( insstr(pub_chapterOneMarker,dchapterOne) + insstr(pub_noFormatMarker,not dformatDocument) + f + #10 );

   end

else begin

   d.sadd( dline.text + #10 );

   end;

end;//loop


//set
result                :=clip__copytext2( @d );

skipend:
except;end;

//free
if (b    <>nil) then faststr__free(@b    );
if (d    <>nil) then faststr__free(@d    );
if (dline<>nil) then faststr__free(@dline);

end;

function pub__paste(const s:tbasicbwp;sbuildFolder:string):boolean;
label
   skipend;

var
   stext              :tstr8;
   ctext              :tstr8;
   cline              :tstr8;
   ctextIsTPUB        :boolean;
   cpos               :longint32;
   f                  :string;

begin

//defaults
result                :=false;
stext                 :=nil;
ctext                 :=nil;
cline                 :=nil;
ctextIsTPUB           :=false;
sbuildFolder          :=io__asfolderNIL( sbuildFolder );

//check
if (s=nil) or (sbuildFolder='') then exit;

try

//init
stext                 :=faststr__new8;
ctext                 :=faststr__new8;
cline                 :=faststr__new8;
cpos                  :=0;

//get
clip__pastetext2( @ctext );

while str__nextline0( @ctext ,@cline ,cpos ) do
begin

if strmatch(cline.text,pub_buildSummary) then
   begin

   ctextIsTPUB        :=true;

   break;

   end;

end;//loop

//set

//.clipboard text is a TPUB
if ctextIsTPUB then
   begin

   s.iosettxt( ctext );

   end

//.clipboard text assumed to be a list of file names
else begin

   s.iogettxt( stext );

   stext.text         :=stext.text + pub_returnCode + ctext.text;

   s.iosettxt( stext );

   end;

//successful
result                :=true;

skipend:
except;end;

//free
if (stext<>nil) then faststr__free(@stext);
if (ctext<>nil) then faststr__free(@ctext);
if (cline<>nil) then faststr__free(@cline);

end;

function pub__safeBuildNumber(const x:longint64):longint64;
begin

if      (x<pub_buildNumber_min) then result:=pub_buildNumber_min

else if (x>pub_buildNumber_max) then result:=add64( 1 ,pub_buildNumber_min )//never zero again

else                                 result:=x;

end;

procedure pub__coverImageDefault(s:tstr8);
begin

if (s<>nil) then
   begin

   s.clear;
   s.aadd( pub_coverImageDefault );

   end;

end;

function pub__fileFormatSupported(const xfilename:string):boolean;
var
   int1     :longint32;

begin

result:=pub__fileFormatSupported2(xfilename,int1);

end;

function pub__fileFormatSupported2(const xfilename:string;var xdocStyle:longint32):boolean;
var
   vname    :string;
   v        :string;

begin

//get
v           :=strlow(io__extractfileext(xfilename));

if (v='txt') or (v='bwd') or (v='bwp') or (v='rtf') then
   begin

   vname    :=strlow(io__extractfilename(xfilename));

   if (vname<>'.__recent.txt')   then xdocStyle:=pub_fText;

   end
else if io__imageExtSupported(v) then xdocStyle:=pub_fImage
else                                  xdocStyle:=pub_fNone;

//set
result      :=(xdocStyle<>pub_fNone);                          

end;

procedure pub__setChapterOneOnce(var xcore:tpubinfo;const dindex:longint32);
begin

if (dindex>=0) and (xcore.firstChapterIndex<0) then
   begin

   xcore.firstChapterIndex      :=dindex;

   end;

end;

function pub__enforceImageLimits(const xcore:tpubinfo;const ximagedata:tstr8;var xoutW,xoutH:longint32):boolean;
var
   a                  :tbasicimage;
   d                  :tbasicimage;
   e                  :string;
   r                  :double;
   dw                 :longint32;
   dh                 :longint32;
   dformat            :string;
   
begin

//defaults
result                :=true;//pass-thru
a                     :=nil;
d                     :=nil;
xoutW                 :=1;
xoutH                 :=1;

//check
if (ximagedata=nil) or (ximagedata.len32<=0) then exit;

try

//init
a                     :=misimg32(1,1);

//get
mis__fromdata( a ,@ximagedata ,e );

dformat               :=io__anyformatb(@ximagedata);
xoutW                 :=a.ai.cellWidth;
xoutH                 :=a.ai.cellHeight;

//check max width/height
if (a.width>pub_maxWidth) or (a.height>pub_maxHeight) then
   begin

   //one cell is ok?
   mis__onecell( a );

   if (a.width<=pub_maxWidth) and (a.height<=pub_maxHeight) then
      begin

      xoutW           :=a.width;
      xoutH           :=a.height;

      ximagedata.clear;

      mis__todata2( a ,@ximagedata ,dformat ,xcore.imageQuality ,e );

      end

   //no, shrink one cell down to an acceptable size
   else begin

      //init
      r               :=a.height / frcmin32(a.width,1);

      if (a.height>pub_maxHeight) then
         begin

         dh           :=pub_maxHeight;
         dw           :=round( a.height * (1/r) );

         end

      else if (a.width>pub_maxWidth) then
         begin

         dw           :=pub_maxWidth;
         dh           :=round( a.width * r );

         end;

      //range
      dw              :=frcmin32(dw,1);
      dh              :=frcmin32(dh,1);
      xoutW           :=dw;
      xoutH           :=dh;

      //get
      d               :=misimg32( dw ,dh );

      mis__copyfast( maxarea ,misarea(a) ,0 ,0 ,dw ,dh ,a ,d );

      //set
      ximagedata.clear;

      mis__todata2( d ,@ximagedata ,dformat ,xcore.imageQuality ,e );

      end;

   end;

except;end;

//free
if (a<>nil) then freeobj(@a);
if (d<>nil) then freeobj(@d);

end;

function pub__stripProtocols(const x:string):string;
label
   redo;

var
   bol1               :boolean;

   function m(const n:string;var v:string):boolean;
   begin

   result             :=strmatch( n ,strcopy1(v,1,low__len32(n)) );

   //strip
   if result then strdel1(v,1,low__len32(n));

   end;

begin

//init
result                :=x;
bol1                  :=false;

//get
redo:

result                :=stripwhitespace_lt( result );

if m( 'http://'  ,result ) then goto redo;
if m( 'https://' ,result ) then goto redo;
if m( 'ftps://'  ,result ) then goto redo;
if m( 'ftp://'   ,result ) then goto redo;
if m( 'mailto:'  ,result ) then goto redo;

end;

function pub__publisher(const x:string):string;
begin

result                :=pub__stripProtocols( x );

end;

procedure pub__formatUp(const x:tstr8);
var
   xlen               :longint32;
   p                  :longint32;
   v                  :longint32;
   s                  :string;

   function c(const xpos0:longint32):char;//read char
   begin

   if (xpos0>=0) and (xpos0<xlen) then result       :=char( x.pbytes[ xpos0 ] )
   else                                result       :=#10;

   end;

   function cstr(const xpos0,xlen:longint32):string;
   var
      p                         :longint32;
      r                         :longint32;

   begin

   if (xlen>=1) then
      begin

      low__setlen( result ,xlen );
      r                         :=0;

      for p:=xpos0 to pred( xpos0 + xlen ) do
      begin


      result[r+stroffset]       :=c(p);

      inc(r);

      end;//p

      end

   else result:='';

   end;

   procedure sc(const xpos0:longint32;const v:byte);//set char
   begin

   if (xpos0>=0) and (xpos0<xlen) then x.pbytes[ xpos0 ]      :=v;

   end;

   procedure nc(const xpos0:longint32);//mark not used
   begin

   if (xpos0>=0) and (xpos0<xlen) then x.pbytes[ xpos0 ]      :=pub_unusedChar;

   end;

   function nn(const xpos0:longint32):boolean;//not a number
   begin

   case byte(c(xpos0)) of

   48..57   :result:=false;
   else      result:=true;

   end;//case

   end;

begin

//check
if (x=nil) then exit
else            xlen  :=x.len32;

//check
if (xlen<=0) then exit;

//get
for p:=0 to pred(xlen) do
begin

case x.pbytes[ p ] of


//em dash ----------------------------------------------------------------------

ssdash:begin

   if (cstr(p,2)='--') and (c(p-1)<>'-') and (c(p+2)<>'-') then//"--" -> 151
      begin

      sc( p ,151 );
      nc( p+1    );

      end

   end;


//eclipse ----------------------------------------------------------------------

ssdot:begin

   if (cstr(p,3)='...') and (c(p-1)<>'.') and (c(p+3)<>'.') then//"..." -> 133
      begin

      sc( p ,133 );
      nc( p+1    );
      nc( p+2    );

      end

   else if (cstr(p,5)='. . .') and (c(p-1)<>'.') and (c(p+5)<>'.') then//". . ." -> 133
      begin

      sc( p ,133 );
      nc( p+1    );
      nc( p+2    );
      nc( p+3    );
      nc( p+4    );

      end;

   end;


//numbers ----------------------------------------------------------------------

nn1:begin

   if nn(p-1) and nn(p+3) then
      begin

      if (cstr(p,3)='1/4') then
         begin

         sc( p ,188 );
         nc( p+1    );
         nc( p+2    );

         end

      else if (cstr(p,3)='1/2') then
         begin

         sc( p ,189 );
         nc( p+1    );
         nc( p+2    );

         end;

      end;

   end;

nn3:begin

   if nn(p-1) and nn(p+3) then
      begin

      if (cstr(p,3)='3/4') then
         begin

         sc( p ,190 );
         nc( p+1    );
         nc( p+2    );

         end;

      end;

   end;

94:begin//"^"

   if nn(p+2) then
      begin

      if (cstr(p,2)='^2') then
         begin

         sc( p ,178 );//power of 2
         nc( p+1    );

         end

      else if (cstr(p,2)='^3') then
         begin

         sc( p ,179 );//power of 3
         nc( p+1    );

         end

      else if (cstr(p,2)='^1') then
         begin

         sc( p ,185 );//power of 1
         nc( p+1    );

         end;

      end;
      
   end;


//strings ----------------------------------------------------------------------

40:begin//"(c)" and "(r)" and "(tm)"

   if (strmatch(cstr(p,3),'(c)')) then
      begin

      sc( p ,169 );
      nc( p+1    );
      nc( p+2    );

      end

   else if (strmatch(cstr(p,3),'(r)')) then
      begin

      sc( p ,174 );
      nc( p+1    );
      nc( p+2    );

      end

   else if (strmatch(cstr(p,4),'(tm)')) then
      begin

      sc( p ,153 );
      nc( p+1    );
      nc( p+2    );
      nc( p+3    );

      end;

   end;

43:begin//"+/-"

   if (cstr(p,3)='+/-') then
      begin

      sc( p ,177 );
      nc( p+1    );
      nc( p+2    );

      end

   end;

end;//case

end;//p

end;

procedure pub__formatSceneSep(const x:tstr8;const xstyle:longint32);//24oct2026
var
   xlen               :longint32;
   p                  :longint32;
   v                  :longint32;
   s                  :string;
   dstyle             :longint32;

   function c(const xpos0:longint32):char;//read char
   begin

   if (xpos0>=0) and (xpos0<xlen) then result       :=char( x.pbytes[ xpos0 ] )
   else                                result       :=#10;

   end;

   function cstr(const xpos0,xlen:longint32):string;
   var
      p                         :longint32;
      r                         :longint32;

   begin

   if (xlen>=1) then
      begin

      low__setlen( result ,xlen );
      r                         :=0;

      for p:=xpos0 to pred( xpos0 + xlen ) do
      begin


      result[r+stroffset]       :=c(p);

      inc(r);

      end;//p

      end

   else result:='';

   end;

   procedure sc(const xpos0:longint32;const v:byte);//set char
   begin

   if (xpos0>=0) and (xpos0<xlen) then x.pbytes[ xpos0 ]      :=v;

   end;

   procedure nc(const xpos0:longint32);//mark not used
   begin

   if (xpos0>=0) and (xpos0<xlen) then x.pbytes[ xpos0 ]      :=pub_unusedChar;

   end;

begin

//check
if (x=nil) then exit
else            xlen  :=x.len32;

//check
if (xlen<=0) then exit;

//range
dstyle                :=frcrange32( xstyle ,pub_sceneSep_min ,pub_sceneSep_max );

//get
for p:=0 to pred(xlen) do
begin

case x.pbytes[ p ] of

sshash:begin

   if (dstyle>=1) then
      begin

      //1 + 3 variations
      if (cstr(p-1,3)=(#10+'#'+#10)) then
         begin

         sc( p ,pub_sceneSep0 )

         end

      else if (cstr(p-2,4)=(#10+' #'+#10)) then
         begin

         nc( p-1 );
         sc( p ,pub_sceneSep0 )

         end

      else if (cstr(p-1,4)=(#10+'# '+#10)) then
         begin

         sc( p ,pub_sceneSep0 );
         nc( p+1 );

         end

      else if (cstr(p-2,5)=(#10+' # '+#10)) then
         begin

         nc( p-1 );
         sc( p ,pub_sceneSep0 );
         nc( p+1 );

         end;

      end;

   end;

ssasterisk:begin

   if (dstyle>=2) then
      begin

      //1 + 3 variations
      if (cstr(p-1,7)=(#10+'* * *'+#10)) then
         begin

         sc( p ,pub_sceneSep0 );
         nc( p+1 );
         nc( p+2 );
         nc( p+3 );
         nc( p+4 );

         end

      else if (cstr(p-1,8)=(#10+' * * *'+#10)) then
         begin

         nc( p-1 );
         sc( p ,pub_sceneSep0 );
         nc( p+1 );
         nc( p+2 );
         nc( p+3 );
         nc( p+4 );

         end

      else if (cstr(p-1,8)=(#10+'* * * '+#10)) then
         begin

         sc( p ,pub_sceneSep0 );
         nc( p+1 );
         nc( p+2 );
         nc( p+3 );
         nc( p+4 );
         nc( p+5 );

         end

      else if (cstr(p-1,9)=(#10+' * * * '+#10)) then
         begin

         nc( p-1 );
         sc( p ,pub_sceneSep0 );
         nc( p+1 );
         nc( p+2 );
         nc( p+3 );
         nc( p+4 );
         nc( p+5 );

         end

      //1 + 3 variations
      else if (cstr(p-1,5)=(#10+'***'+#10)) then
         begin

         sc( p ,pub_sceneSep0 );
         nc( p+1 );
         nc( p+2 );

         end

      else if (cstr(p-1,6)=(#10+'*** '+#10)) then
         begin

         sc( p ,pub_sceneSep0 );
         nc( p+1 );
         nc( p+2 );
         nc( p+3 );

         end

      else if (cstr(p-2,6)=(#10+' ***'+#10)) then
         begin

         nc( p-1 );
         sc( p ,pub_sceneSep0 );
         nc( p+1 );
         nc( p+2 );

         end

      else if (cstr(p-2,7)=(#10+' *** '+#10)) then
         begin

         nc( p-1 );
         sc( p ,pub_sceneSep0 );
         nc( p+1 );
         nc( p+2 );
         nc( p+3 );

         end;

      end;

   end;


//mark these chars as "unused" -> these char codes are reserved for formatting above
pub_sceneSep0 :nc(p);

end;//case

end;//p

end;

procedure pub__quotesSinglePlain(const x:tstr8);
var
   xlen               :longint32;
   p                  :longint32;

begin

//check
if (x=nil) then exit
else            xlen  :=x.len32;

//check
if (xlen<=0) then exit;

//get
for p:=0 to pred(xlen) do
begin

case x.pbytes[ p ] of

145..146    :x.pbytes[ p ]      :=39;//single

end;//case

end;//p

end;

procedure pub__quotesDoublePlain(const x:tstr8);
var
   xlen               :longint32;
   p                  :longint32;

begin

//check
if (x=nil) then exit
else            xlen  :=x.len32;

//check
if (xlen<=0) then exit;

//get
for p:=0 to pred(xlen) do
begin

case x.pbytes[ p ] of

147..148    :x.pbytes[ p ]      :=34;//double

end;//case

end;//p

end;

procedure pub__quotesDoubleCurly(const x:tstr8);
var
   xlen               :longint32;
   p                  :longint32;
   xwithin            :boolean;

   procedure xstart;
   begin

   xwithin         :=true;
   x.pbytes[ p ]   :=147;//double left

   end;

   procedure xstop;
   begin

   xwithin         :=false;
   x.pbytes[ p ]   :=148;//double right

   end;

begin

//check
if (x=nil) then exit
else            xlen  :=x.len32;

//check
if (xlen<=0) then exit;

//init
pub__quotesDoublePlain( x );

xwithin               :=false;

//get
for p:=0 to pred(xlen) do
begin

case x.pbytes[ p ] of

10:xwithin            :=false;//cancel -> keeps processing to a paragraph, preventing any errors from carrying onwards
34:begin

   if xwithin then xstop
   else            xstart;

   end;

end;//case

end;//p

end;

//?????????????????????????????????????//xxxxxxxxxxxxxxxxxxx
procedure pub__quotesSingleCurly(const x:tstr8);
label
   skipone;
   
var
   xlen               :longint32;
   p                  :longint32;
   i                  :longint32;

   function c(const xpos0:longint32):byte;//read char
   begin

   if (xpos0>=0) and (xpos0<xlen) then result       :=x.pbytes[ xpos0 ]
   else                                result       :=10;

   end;

begin

//check
if (x=nil) then exit
else            xlen  :=x.len32;

//check
if (xlen<=0) then exit;

//init
pub__quotesSinglePlain( x );

//get
for p:=0 to pred(xlen) do
begin

case x.pbytes[ p ] of

39:begin

   //xxxxxxxxxxxx needs work//????????????????
//   currently getting " 'cause " wrong in a sentence!!!!!!!!!!!
//?????????????????????????????????????????????????
//?????????????????????????????????????????????????
//?????????????????????????????????????????????????


   //is it a quotation?
   if not windows1252__charIsLetter( c(pred(p)) ) then
      begin

      for i:=succ(p) to xlen do
      begin

      if ( c(i) = 39 ) then
         begin

         if not windows1252__charIsLetter( c(succ(i)) ) then
            begin

            x.pbytes[p]  :=145;//left  "6"
            x.pbytes[i]  :=146;//right "9"
            goto skipone;

            end;

         end;

      end;//i

      end;

   //assume right
   x.pbytes[p]        :=146;//right "9"

   end;

end;//case

skipone:

end;//p

end;

function pub__version:string;
begin

result                :='1.00.2050';

end;


end.

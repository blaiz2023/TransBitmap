unit main;

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
//## Library.................. app code (main.pas)
//## Version.................. 1.00.192 (+2)
//## Items.................... 1
//## Last Updated ............ 27oct2026, 26oct2026
//## Lines of Code............ 1,200+
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
//## | tapp                   | tbasicapp         | 1.00.190  | 27mar2026   | Convert to/from legacy 32-bit bitmap images - 26mar2026
//## ==========================================================================================================================================================================================================================
//## Performance Note:
//##
//## The runtime compiler options "Range Checking" and "Overflow Checking", when enabled under Delphi 3
//## (Project > Options > Complier > Runtime Errors) slow down graphics calculations by about 50%,
//## causing ~2x more CPU to be consumed.  For optimal performance, these options should be disabled
//## when compiling.
//## ==========================================================================================================================================================================================================================

var
   itimerbusy                   :boolean=false;
   iapp                         :tobject=nil;


const
   cvWidth                      =0;
   cvHeight                     =1;
   cvSize                       =2;
   cvColors                     =3;
   cvAlpha                      =4;
   cvTransparent                =5;
   cvMax                        =5;

   eNone                        =0; 
   eError                       =1;
   eAll                         =2;


   backindexNames               :array[0..3] of string    =( 'White' ,'Grey' ,'Black' ,'Window' );
   backindexValues              :array[0..3] of longint32 =( int_255_255_255 ,int_127_127_127 , 0 ,-1 );
   backindex_def                =0;

type


{tapp}
   tapp=class(tbasicapp)
   private

    ibuildingcontrol            :boolean;
    iloaded                     :boolean;
    itimer100                   :longint64;
    itimer250                   :longint64;
    itimer500                   :longint64;
    iimage                      :trawimage;
    imustCountColors            :boolean;
    icolorCount                 :longint32;
    ialphaCount                 :longint32;
    itransparent                :boolean;
    iview                       :tbasicimgview;
    ibar                        :tbasictoolbar;
    ibackindex                  :longint32;
    ilastclipid                 :longint32;
    iautopastecopy              :boolean;
    isettingsref                :string;
    ilastopenfile               :string;
    ilastopenIndex              :longint32;

    procedure __onclick(sender:tobject);
    procedure __ontimer(sender:tobject); override;
    procedure xloadsettings;
    procedure xsavesettings;
    procedure xautosavesettings;
    procedure xshowmenuFill1(sender:tobject;xstyle:string;xmenudata:tstr8;var ximagealign:longint;var xmenuname:string);
    function  xshowmenuClick1(sender:tbasiccontrol;xstyle:string;xcode:longint;xcode2:string;xtepcolor:longint):boolean;
    procedure xclickcell(sender:tobject);
    procedure xupdateButtons;
    function xfindHelp(const n:string):string;
    function  clip__changed:boolean;

    function  xpastecopy (const eshow:longint32;const eshort:boolean):boolean;
    function  xpaste     (const eshow:longint32;const eshort:boolean):boolean;
    function  xcopy      (const eshow:longint32;const eshort:boolean):boolean;
    procedure xload;
    procedure xopencopy;
    procedure xpastesave;

    //other
    function xonaccept(sender:tobject;xfolder,xfilename:string;xindex,xcount:longint):boolean;

   public

    //create
    constructor create; virtual;
    destructor destroy; override;

    //support
    procedure xcmd(sender:tobject;xcode:longint;xcode2:string);

   end;


//info procs -------------------------------------------------------------------
function  app__info(xname:string):string;
function  info__app(xname:string):string;//information specific to this unit of code - 20jul2024: program defaults added, 23jun2024


//app procs --------------------------------------------------------------------
//.remove / create / destroy
procedure app__remove;//does not fire "app__create" or "app__destroy"
procedure app__create;
procedure app__destroy;

//.event handlers
function  app__onmessage(m:msg_message;w:msg_wparam;l:msg_lparam):msg_result;//17dec2025
procedure app__onpaintOFF;//called when screen was live and visible but is now not live, and output is back to line by line
procedure app__onpaint(sw,sh:longint);
procedure app__ontimer;

//.support procs
function  app__netmore:tnetmore;//optional - return a custom "tnetmore" object for a custom helper object for each network record -> once assigned to a network record, the object remains active and ".clear()" proc is used to reduce memory/clear state info when record is reset/reused
procedure app__customTEP(const xindex:longint);
function  app__syncandsavesettings:boolean;


implementation

uses gossdat;


//info procs -------------------------------------------------------------------
function app__info(xname:string):string;
begin
result:=info__rootfind(xname);
end;

function info__app(xname:string):string;//information specific to this unit of code - 20jul2024: program defaults added, 23jun2024
begin
//defaults
result:='';

try
//init
xname:=strlow(xname);

//get
if      (xname='slogan')              then result:=info__app('name')+' by Blaiz Enterprises'
else if (xname='width')               then result:='950'
else if (xname='height')              then result:='750'

else if (xname='language')            then result:='english-australia'//for Clyde - 14sep2025
else if (xname='codepage')            then result:='1252'
else if (xname='msix.tags')           then result:='-'//for Clyde - 31jan2026
else if (xname='msstore.name')        then result:='BlaizTransBitmap'//optional - overrides default name for Clyde - 15apr2026


else if (xname='ver')                 then result:='1.00.192'
else if (xname='date')                then result:='27oct2026'
else if (xname='name')                then result:='Trans Bitmap'
else if (xname='web.name')            then result:='transbitmap'//used for website name
else if (xname='des')                 then result:='Open, copy, paste, and save legacy 32-bit transparent bitmap images'
else if (xname='infoline')            then result:=info__app('name')+#32+info__app('des')+' v'+app__info('ver')+' (c) 1997-'+low__yearstr(2024)+' Blaiz Enterprises'
else if (xname='size')                then result:=low__b(io__filesize64(io__exename),true)
else if (xname='diskname')            then result:=io__extractfilename(io__exename)
else if (xname='service.name')        then result:=info__app('name')
else if (xname='service.displayname') then result:=info__app('service.name')
else if (xname='service.description') then result:=info__app('des')

//.links and values
else if (xname='linkname')            then result:=info__app('name')+' by Blaiz Enterprises.lnk'
else if (xname='linkname.vintage')    then result:=info__app('name')+' (Vintage) by Blaiz Enterprises.lnk'

//.author
else if (xname='author.shortname')    then result:='Blaiz'
else if (xname='author.name')         then result:='Blaiz Enterprises'
else if (xname='portal.name')         then result:='Blaiz Enterprises - Portal'
else if (xname='portal.tep')          then result:=intstr32(tepBE20)

//.software
else if (xname='url.software')        then result:='https://www.blaizenterprises.com/'+info__app('web.name')+'.html'
else if (xname='url.software.zip')    then result:='https://www.blaizenterprises.com/'+info__app('web.name')+'.zip'

//.urls
else if (xname='url.portal')          then result:='https://www.blaizenterprises.com'
else if (xname='url.contact')         then result:='https://www.blaizenterprises.com/contact.html'
else if (xname='url.facebook')        then result:='https://web.facebook.com/blaizenterprises'
else if (xname='url.mastodon')        then result:='https://mastodon.social/@BlaizEnterprises'
else if (xname='url.twitter')         then result:='https://twitter.com/blaizenterprise'
else if (xname='url.x')               then result:=info__app('url.twitter')
else if (xname='url.instagram')       then result:='https://www.instagram.com/blaizenterprises'
else if (xname='url.sourceforge')     then result:='https://sourceforge.net/u/blaiz2023/profile/'
else if (xname='url.github')          then result:='https://github.com/blaiz2023'

//.program/splash
else if (xname='license')             then result:='MIT License'
else if (xname='copyright')           then result:='© 1997-'+low__yearstr(2026)+' Blaiz Enterprises'
else if (xname='splash.web')          then result:='Web Portal: '+app__info('url.portal')

else
   begin
   //nil
   end;

except;end;
end;


//app procs --------------------------------------------------------------------
procedure app__create;
begin
{$ifdef gui}
iapp:=tapp.create;
{$else}

//.starting...
app__writeln('');
//app__writeln('Starting server...');

//.visible - true=live stats, false=standard console output
scn__setvisible(false);


{$endif}
end;

procedure app__remove;
begin
//reserved
end;

procedure app__destroy;
begin
try
//save
//.save app settings
app__syncandsavesettings;

//free the app
freeobj(@iapp);

except;end;
end;

function app__syncandsavesettings:boolean;
begin
//defaults
result:=false;
try
//.settings
{
app__ivalset('powerlevel',ipowerlevel);
app__ivalset('ramlimit',iramlimit);
{}


//.save
app__savesettings;

//successful
result:=true;
except;end;
end;

function app__netmore:tnetmore;//optional - return a custom "tnetmore" object for a custom helper object for each network record -> once assigned to a network record, the object remains active and ".clear()" proc is used to reduce memory/clear state info when record is reset/reused
begin
result:=tnetbasic.create;
end;

procedure app__customTEP(const xindex:longint);

   procedure mc(const sm ,sc:array of byte);//mono + color
   begin

   tep__20( xindex ,sm ,sc ,it_rle8 ,it_img32 );

   end;

   procedure m(const sm:array of byte);//mono only
   begin

   tep__20( xindex ,sm ,[0] ,it_rle8 ,it_img32 );

   end;

   procedure m32(const sm:array of byte);//mono only
   begin

   tep__32( xindex ,sm ,[0] ,it_rle8 ,it_img32 );

   end;

   procedure c(const sc:array of byte);//color only
   begin

   tep__20( xindex ,[0] ,sc ,it_rle8 ,it_img32 );

   end;

   procedure m6(const sm:array of byte);//mono only
   begin

   tep__20( xindex ,sm ,[0] ,it_rle6 ,it_img32 );

   end;

begin

{
case xindex of
tepScrollDown20       :m( mtep_ScrollDown20    );
end;//case
{}

end;

function app__onmessage(m:msg_message;w:msg_wparam;l:msg_lparam):msg_result;//17dec2025
begin
//defaults
result:=0;
end;

procedure app__onpaintOFF;//called when screen was live and visible but is now not live, and output is back to line by line
begin
//nil
end;

procedure app__onpaint(sw,sh:longint);
begin
//console app only
end;

procedure app__ontimer;
begin
try

//lock check
if itimerbusy then exit else itimerbusy:=true;//prevent sync errors

//last timer - once only
if app__lasttimer then
   begin

   end;

//check
if not app__running then exit;


//first timer - once only
if app__firsttimer then
   begin

   end;

except;end;

//unlock
itimerbusy:=false;

end;


//misc procs -------------------------------------------------------------------

function low__datestr0(x:tdatetime):string;
var
    yy,mm,dd,hh,min,ss,ms:word;
begin

low__decodedate2(x,yy,mm,dd);
low__decodetime2(x,hh,min,ss,ms);
result:=intstr32(yy)+'y-'+intstr32(mm)+'m-'+intstr32(dd)+'d-'+intstr32(hh)+'h-'+intstr32(min)+'m-'+intstr32(ss)+'s-'+intstr32(ms)+'ms';

end;


//## tapp ######################################################################

constructor tapp.create;
var
   p                  :longint32;
   str1               :string;

begin


//win__make_gosswin2_pas;

if system_debug then dbstatus(38,'Debug 010 - 21may2021_528am');//yyyy

//needers - 26sep2021
need_jpeg;
need_gif;

if system_debug then dbstatus(38,'Debug 012');//yyyy


//self
inherited create(strint32(app__info('width')),strint32(app__info('height')));

ibuildingcontrol                :=true;
iloaded                         :=false;


//vars
itimer100                       :=slowms64;
itimer250                       :=slowms64;
itimer500                       :=slowms64;
isettingsref                    :='';
ilastopenfile                   :=strcopy1(app__folder,1,3)+'Untitled.bmp';
ilastopenIndex                  :=0;
iimage                          :=misraw32(32,32);

misclsarea3(iimage,maxarea,0,0,255,255);

icolorCount                     :=0;
ialphaCount                     :=0;
itransparent                    :=false;
ibackindex                      :=backindex_def;
iautopastecopy                  :=false;
ilastclipid                     :=-1;

//controls
with rootwin do
begin
scroll                          :=false;

xhead;

with xhead do
begin

add('Paste and Copy',tepPaste20,0,'pastecopy' ,xfindHelp('pastecopy') );

addsep;

end;


//root columns -----------------------------------------------------------------

xcols.style                     :=bcLefttoright;
xcols.hsp                       :=0;

//.left
with xcols.cols2[ 0 ,75 ,false ] do
begin

iview                           :=nimgview;
iview.oautoheight               :=true;

end;

//.middle
with xcols.cols2[ 1 ,1 ,false ] do
begin

normal                          :=false;

end;

//.right
with xcols.cols2[ 2 ,20 ,false ] do
begin

ibar                            :=client.ntoolbar('');
ibar.normal                     :=true;

with ibar do
begin

//.heading
hcsadd('Actions',tepNone,0,'header.1','',-99);
btitle2['header.1']             :=true;

sadd('Open and Copy',tepOpen20,0,'opencopy',xfindhelp('opencopy'),-99,0);

newline;
sadd('Paste and Save',tepSave20,0,'pastesave',xfindhelp('pastesave'),-99,0);

newPartLine;
newline;
sadd('Copy Image',tepCopy20,0,'copy',xfindHelp('copy'),-99,0);

newline;
sadd('Paste Image',tepPaste20,0,'paste',xfindHelp('paste'),-99,0);

newline;
sadd('Paste and Copy',tepPaste20,0,'pastecopy' ,xfindHelp('pastecopy') ,-99,0);

newline;
sadd('Auto. Paste and Copy',tepRefresh20,0,'auto',xfindhelp('auto'),-99,0);

newPartLine;
newline;

//.heading
hcsadd('Preview Background',tepNone,0,'header.2','',-99);
btitle2['header.2']             :=true;

//.options
for p:=0 to high(backindexNames) do
begin

sadd( backindexNames[p],tepColors20,0,'backindex.'+intstr32(p),'Preview Background Color|Set preview background color to '+strlow(backindexNames[p])+'.',0,0);

if (p=1) then newline;

end;//p

end;//ibar

end;

//left
with xstatus2 do
begin

//.cell widths
cellwidth[cvWidth         ]:=150;
cellwidth[cvHeight        ]:=150;
cellwidth[cvSize          ]:=180;
cellwidth[cvColors        ]:=140;
cellwidth[cvAlpha         ]:=160;
cellwidth[cvTransparent   ]:=200;
cellwidth[cvMax+1         ]:=200;

//.cell help
cellhelp[cvWidth          ]:='Width of image in pixels (px)';
cellhelp[cvHeight         ]:='Height of image in pixels (px)';
cellhelp[cvSize           ]:='Size of image';
cellhelp[cvColors         ]:='Image colors';
cellhelp[cvAlpha          ]:='Image alpha shades';
cellhelp[cvTransparent    ]:='Image transparency status';

end;//left

//.last links on toolbar - 22mar2021
with xhead do
begin

xaddoptions;
xaddhelp;

end;


//events
rootwin.xhead.onclick           :=__onclick;
rootwin.xhead.showmenuFill1     :=xshowmenuFill1;
rootwin.xhead.showmenuClick1    :=xshowmenuClick1;
rootwin.xhead.ocanshowmenu      :=true;//use toolbar for special menu display - 18dec2021
ibar.onclick                    :=__onclick;
rootwin.xstatus2.clickcell      :=xclickcell;
rootwin.onaccept                :=xonaccept;

end;//rootwin


//start
ibuildingcontrol                :=false;
xloadsettings;
xload;


//finish
createfinish;

end;


destructor tapp.destroy;
begin
try

//settings
xautosavesettings;

//vars
freeobj(@iimage);

//self
inherited destroy;

except;end;
end;

function tapp.clip__changed:boolean;
begin

result                          :=low__setint(ilastclipid,win____getclipboardsequenceNumber);

end;

function tapp.xfindHelp(const n:string):string;

   function m(const v:string):boolean;
   begin

   result   :=strmatch(n,v);

   end;

   function xsyncStr:string;
   begin

   result   := '|*|Synchronises the image as a PNG, V5 Bitmap, and DIB Bitmap (legacy support) on the Windows Clipboard for maximum inter-app compatibility.';

   end;

begin

if      m('pastecopy') then result:= 'Paste and Copy|Paste image from Clipboard, convert, and copy image back to Clipboard.'+xsyncStr
else if m('copy')      then result:= 'Copy Image|Copy image to Clipboard.'+xsyncstr
else if m('paste')     then result:= 'Paste Image|Paste image from Clipboard.'
else if m('auto')      then result:= 'Automatic Paste and Copy|Automatically paste image from Clipboard, convert, and copy image back to Clipboard for seamless app-to-app copy/paste functionality.'+xsyncStr
else if m('opencopy')  then result:= 'Open and Copy Image|Open image from file and copy to Clipboard.'+xsyncstr
else if m('pastesave') then result:= 'Paste and Save Image|Paste image from Clipboard and save to file.|*|If saving as a BMP (bitmap), the image will be saved at 24-bit when solid, and at 32-bit with legacy 8-bit alpha mask support when transparent.'
else                        result:= '';

end;

function tapp.xonaccept(sender:tobject;xfolder,xfilename:string;xindex,xcount:longint):boolean;
var
   e                  :string;

begin

//first filename only
result                :=false;

//get
if io__fileexists(xfilename) then
   begin

   mis__fromfile( iimage ,xfilename ,e );

   xload;

   if iautopastecopy then xcopy( eAll ,false );

   end;

end;

procedure tapp.xclickcell(sender:tobject);
begin

if (sender is tbasicstatus) and ((sender as tbasicstatus).clickname<>'') then xcmd(nil,0, (sender as tbasicstatus).clickname );

end;

procedure tapp.xshowmenuFill1(sender:tobject;xstyle:string;xmenudata:tstr8;var ximagealign:longint;var xmenuname:string);
begin

if zznil(xmenudata,5000) then exit;

end;

function tapp.xshowmenuClick1(sender:tbasiccontrol;xstyle:string;xcode:longint;xcode2:string;xtepcolor:longint):boolean;
begin

//handled
result                          :=true;

//get
//if low__comparetext(strcopy1(xcode2,1,4),'new.') then xcmd(nil,0,xcode2)
//else
result                          :=false;

end;

procedure tapp.xloadsettings;
var
   a                            :tvars8;
   p                            :longint32;

begin

//defaults
a                               :=nil;

//check
if zznil(prgsettings,5001) then exit;

try

//init
a                               :=vnew2(950);

//filter
a.i['backindex']                :=prgsettings.idef2( 'backindex' ,backindex_def ,0 ,high(backindexNames) );
a.b['autopastecopy']            :=prgsettings.bdef ( 'autopastecopy' ,false );

//sync
prgsettings.data                :=a.data;

//set
ibackindex                      :=a.i['backindex'];
iautopastecopy                  :=a.b['autopastecopy'];


except;end;

//free
freeobj(@a);

iloaded                         :=true;

//sync
xupdateButtons;

end;

procedure tapp.xsavesettings;
var
   a                            :tvars8;
   p                            :longint32;

begin

//defaults
a                               :=nil;

//check
if not iloaded then exit;

try

//init
a                               :=vnew2(951);

//get
a.i['backindex']                :=ibackindex;
a.b['autopastecopy']            :=iautopastecopy;

//set
prgsettings.data                :=a.data;

siSaveprgsettings;

except;end;

//free
freeobj(@a);

end;

procedure tapp.xautosavesettings;
var
   bol1                         :boolean;

begin

//check
if not iloaded then exit;

try

//get
bol1                            :=false;

//.check
if low__setstr( isettingsref ,bolstr(iautopastecopy)+'|'+intstr32(ibackindex) ) then bol1:=true;

//set
if bol1 then xsavesettings;

except;end;
end;

procedure tapp.__onclick(sender:tobject);
begin

xcmd(sender,0,'');

end;

procedure tapp.xcmd(sender:tobject;xcode:longint;xcode2:string);
label
   redonew,skipend;

var
   p                            :longint32;
   v                            :string;
   v32                          :longint32;

   function m(const n:string):boolean;
   begin

   result                       :=strmatch( n ,xcode2 );

   end;

   function mv(const n:string):boolean;
   begin

   result                       :=strm( xcode2 ,n ,v ,v32 );

   end;

begin
try

//init
if (sender is tbasictoolbar) then
   begin

   //ours next
   xcode                        :=(sender as tbasictoolbar).ocode;
   xcode2                       :=strlow((sender as tbasictoolbar).ocode2);

   end;

//get
if      m('pastecopy')  then xpastecopy ( eAll ,false )
else if m('paste')      then xpaste     ( eAll ,false )
else if m('copy')       then xcopy      ( eAll ,false )

else if m('auto')       then iautopastecopy:=not iautopastecopy

else if m('opencopy')   then xopencopy
else if m('pastesave')  then xpastesave

else if mv('backindex.') then
   begin

   ibackindex                   :=frcrange32( v32 ,0 ,high(backindexValues) );

   end

else begin

   if system_debug then showbasic('Unknown Command>'+xcode2+'<<');

   end;

skipend:

except;end;

//sync
xupdateButtons;

end;

procedure tapp.__ontimer(sender:tobject);//._ontimer
begin
try

//init

//timer100
if (ms64>=itimer100) and iloaded then
   begin

   //reset
   itimer100                    :=add64( ms64 ,100 );

   end;


//timer250
if (ms64>=itimer250) then
   begin

   //autopastecopy -> ignore enhanced formats ( e.g. pascal arrays, base64 => plain text ) - 26oct2026
   if iautopastecopy and clip__changed and clip__canpasteimage(false) then xpastecopy( eAll ,true );

   //reset
   itimer250                    :=add64( ms64 ,150 );

   end;

//timer500
if (ms64>=itimer500) then
   begin

   //updateButtons
   xupdateButtons;

   //savesettings
   xautosavesettings;

   //reset
   itimer500                    :=add64( ms64 ,500 );

   end;


//debug support
if system_debug then
   begin

   if system_debugFAST then rootwin.paintallnow;

   end;

if system_debug and system_debugRESIZE then
   begin
   //if (system_debugwidth<=0) then system_debugwidth:=gui.host.width;
   //if (system_debugheight<=0) then system_debugheight:=gui.host.height;
   //change the width and height to stress
   //was: if (random(10)=0) then gui.setbounds(gui.left,gui.top,system_debugwidth+random(32)-16,system_debugheight+random(128)-64);
   //gui.setbounds(gui.left,gui.top,system_debugwidth+random(32)-16,system_debugheight+random(128)-64);
   end;

except;end;
end;

procedure tapp.xupdateButtons;
var
   xmustCount                   :boolean;
   xcanpaste                    :boolean;
   dbackcolor                   :longint32;
   p                            :longint32;
   dbits                        :longint32;

begin
try

//init
xmustCount                      :=imustCountColors;
imustCountColors                :=false;
xcanpaste                       :=clip__canpasteimage( true );//suports enhanced formats

//color count
if xmustCount then
   begin

   icolorCount                  :=miscountcolors( iimage );
   ialphaCount                  :=mask__count( iimage );
   itransparent                 :=mask__hasTransparency32( iimage );

   end;

dbits                           :=low__aorb(24,32,itransparent);


//backcolor
dbackcolor                      :=backindexValues[ ibackindex ];
if (dbackcolor=-1) then
   begin

   dbackcolor                   :=vinormal.background;

   end;

iview.backcolor                 :=dbackcolor;


//.buttons
with rootwin.xhead do
begin

benabled2['pastecopy']          :=xcanpaste;
benabled2['paste']              :=xcanpaste;
benabled2['pastesave']          :=xcanpaste;

end;

//.ibar
with ibar do
begin

benabled2['pastecopy']          :=xcanpaste;
benabled2['paste']              :=xcanpaste;
bmarked2 ['auto']               :=iautopastecopy;
bflash2  ['auto']               :=iautopastecopy;

for p:=0 to high(backindexValues) do
begin

bmarked2['backindex.'+intstr32(p)]        :=(p=ibackindex);
bflash2 ['backindex.'+intstr32(p)]        :=(p=ibackindex);

end;//p

end;

//.status2
with rootwin.xstatus2 do
begin

celltext[cvWidth          ]               :='Width '+k64(misw( iimage ))+' px';
celltext[cvHeight         ]               :='Height '+k64(mish( iimage ))+' px';
celltext[cvSize           ]               :='Size '+low__mbAUTO2( misw(iimage) * mish(iimage) * round32(dbits/8) ,3 ,true );
celltext[cvColors         ]               :='Colors '+k64( icolorCount );
celltext[cvAlpha          ]               :='Alpha Shades '+k64( ialphaCount );
celltext[cvTransparent    ]               :=low__aorbstr('Solid','Transparent',itransparent);

end;

except;end;
end;

function tapp.xpastecopy (const eshow:longint32;const eshort:boolean):boolean;
begin

result                :=xpaste( low__aorb(eNone,eError,eshow>=eError) ,eshort ) and xcopy( low__aorb(eNone,eError,eshow>=eError) ,eshort );

if result and (eshow>=eAll) then gui.popstatus('Pasted and copied image to Clipboard',1);

end;

function tapp.xpaste(const eshow:longint32;const eshort:boolean):boolean;
begin

//defaults
result                          :=false;

//sync
clip__changed;

//get
if clip__pasteimage( iimage ,true ) then
   begin

   xload;

   result                       :=true;

   end;

//show
case result of
true:if (eshow>=eAll) then gui.popstatus('Pasted image from Clipboard',1);
else if (eshow>=eError) then gui.popstatus('Paste failed' ,low__aorb(3,1,eshort) );
end;//case

end;

function tapp.xcopy(const eshow:longint32;const eshort:boolean):boolean;
begin

//get

//Note: ia_32bitPLUS -> forces a PNG onto the Clipboard even when not transparent, and at 32-bit, which auto. enables
//                      Gimp to use its eraser on the alpha channel WITHOUT having to instruct Gimp to make an alpha
//                      channel - 27oct2026
result                          :=clip__copyimage2( iimage ,ia_bmp_legacyAlpha+ia_sep+ia_32bitPLUS );

//sync
clip__changed;

//show
case result of
true:if (eshow>=eAll) then gui.popstatus('Copied image to Clipboard',1);
else if (eshow>=eError) then gui.popstatus('Copy failed' ,low__aorb(3,1,eshort) );
end;//case

end;

procedure tapp.xload;
var
   b                         :tstr8;
   e                         :string;

begin

//defaults
b                            :=nil;

try

//sync
clip__changed;

//init
b                            :=faststr__new8;

//get
mis__onecell( iimage );

mis__todata( iimage ,@b ,'bmp' ,e );

iview.loadfromdata( @b ,true );

imustCountColors             :=true;

xupdateButtons;

except;end;

//free
if (b<>nil) then faststr__free(@b);

end;

procedure tapp.xopencopy;
var
   xok                          :boolean;
   e                            :string;

begin

//prompt
if gui.popopenimg( ilastopenfile ,ilastopenIndex, '' ) then
   begin

   //open
   xok                          :=mis__fromfile1( iimage ,ilastopenfile ,ia_bmp_legacyAlpha ,e );
   xload;

   //error
   if not xok then
      begin

      gui.popstatus(e,3);

      exit;

      end;

   //copy
   xcopy( eAll ,true );

   end;

end;

procedure tapp.xpastesave;
var
   xok                          :boolean;
   e                            :string;
   xaction                      :string;

begin

//paste
xpaste( eError ,true );

//prompt
if gui.popsaveimg( ilastopenfile ,'' ,xaction ) then
   begin

   //save
   xok                          :=mis__tofile2( iimage ,ilastopenfile ,io__extractfileext(ilastopenfile) ,ia_bmp_legacyAlpha+ia_sep+ia_24bitplus ,e );

   //error
   if not xok then
      begin

      gui.popstatus(e,3);

      end;

   end;

end;

end.

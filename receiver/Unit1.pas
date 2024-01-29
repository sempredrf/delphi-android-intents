unit Unit1;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  System.Messaging,
  System.DateUtils,

  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Dialogs,
  FMX.StdCtrls,
  FMX.Platform.Android,
  FMX.Controls.Presentation,
  FMX.Layouts,
  FMX.Memo.Types,
  FMX.ScrollBox,
  FMX.Memo,
  FMX.Platform,

  Androidapi.JNI.GraphicsContentViewText,
  Androidapi.Helpers,
  Androidapi.JNI.JavaTypes,
  Androidapi.JNI.Os,
  Androidapi.JNI.App;

type
  TForm1 = class(TForm)
    Label1: TLabel;
    Layout1: TLayout;
    Layout2: TLayout;
    Layout3: TLayout;
    Memo1: TMemo;
    Layout4: TLayout;
    Button1: TButton;
    Button2: TButton;
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    FExtras : JBundle;

    { Private declarations }
    function HandleAppEvent(AAppEvent: TApplicationEvent; AContext: TObject): Boolean;

    procedure HandleIntentAction(const aData: JIntent);
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

procedure TForm1.Button1Click(Sender: TObject);
var
  replyIntent : JIntent;
  sData : string;
begin
  if FExtras <> nil then
  begin
    sData := JStringToString( FExtras.getString( TJIntent.JavaClass.EXTRA_TEXT ) );
    sData := Format('%S - %S ', [sData, DateTimeToStr(now)] );

    replyIntent := TJIntent.Create();
    replyIntent.putExtra(StringToJString('data'), StringToJString(sData));

    TAndroidHelper.Activity.setResult(TJActivity.JavaClass.RESULT_OK,
                                      replyIntent);
    TAndroidHelper.Activity.finish();
  end
  else
    ShowMessage('Cannot find any data!')
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  TAndroidHelper.Activity.setResult(TJActivity.JavaClass.RESULT_CANCELED);
  TAndroidHelper.Activity.finish();
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  AppEventService: IFMXApplicationEventService;
begin
  if TPlatformServices.Current.SupportsPlatformService( IFMXApplicationEventService, AppEventService ) then
    AppEventService.SetApplicationEventHandler( HandleAppEvent );

  // Register the type of intent action that we want to be able to receive.
  // Note: A corresponding <action> tag must also exist in the <intent-filter> section of AndroidManifest.template.xml.
  MainActivity.registerIntentAction( StringToJString('MY_ACTION') );
  //Memo1.Lines.Add('deviceID: ' + JStringToString( MainActivity.getDeviceID ));
end;

function TForm1.HandleAppEvent(AAppEvent: TApplicationEvent;
  AContext: TObject): Boolean;
var
  StartupIntent: JIntent;
begin
  Result := False;

  if AAppEvent = TApplicationEvent.BecameActive then
  begin

    StartupIntent := MainActivity.getIntent;

    if StartupIntent <> nil then
      HandleIntentAction( StartupIntent );
  end;
end;

procedure TForm1.HandleIntentAction(const aData: JIntent);
var
  sData : string;
begin

  if aData <> nil then
  begin
    try
      try
        FExtras := aData.getExtras;

        if FExtras <> nil then
        begin
          sData := JStringToString( FExtras.getString( TJIntent.JavaClass.EXTRA_TEXT ) );
          Memo1.Lines.Add('data: ' + sData );
        end;
      except
        on e : exception do
        begin
          Memo1.Lines.Add('error: ' + e.Message );

          TAndroidHelper.Activity.setResult(TJActivity.JavaClass.RESULT_CANCELED);
          TAndroidHelper.Activity.finish();
        end;
      end;
    finally
      Invalidate;
    end;
  end;

end;

end.

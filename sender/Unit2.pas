unit Unit2;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  System.Messaging,

  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.Layouts,
  FMX.StdCtrls,
  FMX.Controls.Presentation,
  FMX.Platform.Android,
  FMX.Memo.Types,
  FMX.ScrollBox,
  FMX.Memo,

  Androidapi.JNI.JavaTypes,
  Androidapi.JNI.GraphicsContentViewText,
  Androidapi.Helpers,
  Androidapi.JNI.Os;

type
  TForm2 = class(TForm)
    Layout1: TLayout;
    Layout2: TLayout;
    Label1: TLabel;
    Layout3: TLayout;
    Button1: TButton;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
    FRequestCode : integer;

    procedure HandleActivityMessage(const Sender: TObject; const M: TMessage);
    procedure OnActivityResult(aRequestCode, aResultCode: Integer;
  aData: JIntent);
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.fmx}

procedure TForm2.Button1Click(Sender: TObject);
var
  Intent: JIntent;
begin
  Memo1.ClearContent();
  FRequestCode := Random(100);
  Memo1.Lines.Add( FRequestCode.ToString );

  Intent := TJIntent.JavaClass.init(StringToJString('com.embarcadero.myReceiver.MY_ACTION'));

  if Intent.resolveActivity(TAndroidHelper.Context.getPackageManager) <> nil then
  begin
    Intent.putExtra(TJIntent.JavaClass.EXTRA_TEXT, StringToJString('hello world'));
    TMessageManager.DefaultManager.SubscribeToMessage(TMessageResultNotification, HandleActivityMessage);
    TAndroidHelper.Activity.startActivityForResult(Intent, FRequestCode);
  end
  else
    ShowMessage('Cannot find receiver!');
end;

procedure TForm2.HandleActivityMessage(const Sender: TObject;
  const M: TMessage);
begin
  if M is TMessageResultNotification then
    OnActivityResult(TMessageResultNotification(M).RequestCode,
                     TMessageResultNotification(M).ResultCode,
                     TMessageResultNotification(M).Value);
end;

procedure TForm2.OnActivityResult(aRequestCode, aResultCode: Integer;
  aData: JIntent);
var
  ResultNotification: TMessageResultNotification;
  sData : string;
  extras: JBundle;
begin
  if aRequestCode = FRequestCode then
  begin
    TMessageManager.DefaultManager.Unsubscribe(TMessageResultNotification, FRequestCode);
    try
      sData := 'NULL DATA';

      if aData <> nil then
      begin
        sData := 'NULL EXTRAS';

        extras := aData.getExtras;

        if extras <> nil then
          sData := JStringToString( extras.getString(StringToJString('data')) );
      end;

      Memo1.Lines.Add('requestCode: ' + aRequestCode.ToString);
      Memo1.Lines.Add('resultCode: ' + aResultCode.ToString);
      Memo1.Lines.Add('data: ' + sData );
    except
      on e : Exception do
        Memo1.Lines.Add('exception: ' + e.Message );
    end;
  end;
end;

end.

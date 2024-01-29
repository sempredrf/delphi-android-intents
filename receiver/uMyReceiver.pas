unit uMyReceiver;

interface

uses
  FMX.Platform,
  FMX.Helpers.Android,
  Androidapi.JNIBridge,
  Androidapi.JNI.Embarcadero,
  Androidapi.JNI.GraphicsContentViewText,
  Androidapi.JNI.JavaTypes,
  Androidapi.JNI.Util,
  Androidapi.Helpers;
type
  [BroadcastReceiver]
  [IntentFilterAttribute(TJIntent.JavaClass.ACTION)]
  TMyReceiver = class(TJFMXBroadcastReceiver)
  public
    procedure onReceive(context: JContext; intent: JIntent); cdecl;
  end;

implementation

uses
  FMX.Dialogs;

procedure TMyReceiver.onReceive(context: JContext; intent: JIntent);
var
  message: JString;
begin
  // Processar a mensagem recebida do Intent
  if intent <> nil then
  begin
    message := intent.getStringExtra(TJIntent.JavaClass.EXTRA_TEXT);
    ShowMessage('Mensagem recebida: ' + JStringToString(message));

    // Você pode processar a mensagem conforme necessário aqui
  end;
end;

end.

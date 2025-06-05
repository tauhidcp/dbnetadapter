unit ServerUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
  ZeosProv, MemDataBase, ZeosDataServer, ZConnection, DB, ServerProc,
  DataProcUtils;

type

  { TServerForm }

  TServerForm = class(TForm)
    ZConnection1: TZConnection;
    ZeosDataServer1: TZeosDataServer;
    function ZeosDataServer1CustInternalCall(CustInstruc, CustSubInstruc: byte;
      CliParam: PChar; DataQuery: TServerSockQuery; DataSQLProc: TServerSockQuery;
      DataStoredProc: TServerSockQuery;
      User, SubFunctions: TNetProcString): TNetProcString;
    function ZeosDataServer1UserLogonCall(UserName, Password: TNetProcString):
      TLogonStyle;
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  ServerForm: TServerForm;

implementation

{$R *.lfm}

{ TServerForm }

function TServerForm.ZeosDataServer1CustInternalCall(CustInstruc, CustSubInstruc: byte;
  CliParam: PChar; DataQuery: TServerSockQuery; DataSQLProc: TServerSockQuery;
  DataStoredProc: TServerSockQuery;
  User, SubFunctions: TNetProcString): TNetProcString;
begin
  {Now it is not internal thin query demo
  case CustInstruc of
    byte(InstrucInternalOpen):
    begin
      if CustSubInstruc = 1 then
        Result := 'select * from biolife';
    end;
    102:
    begin

    end;
    103:
    begin

    end
    else

  end;     }
end;

function TServerForm.ZeosDataServer1UserLogonCall(UserName, Password:
  TNetProcString): TLogonStyle;
begin
  //Caption := UserName;
  Result := LogedOnServer;
end;

end.


{==============================================================================|
| Project : OnLine Data Process Component                                      |
|==============================================================================|
| Copyright (c)2010-2011, Yang JiXian                                          |
| All rights reserved.                                                         |
|                                                                              |
| Redistribution and use in source and binary forms, with or without           |
| modification, are permitted provided that the following conditions are met:  |
|                                                                              |
| Redistributions of source code must retain the above copyright notice, this  |
| list of conditions and the following disclaimer.                             |
|                                                                              |
| Redistributions in binary form must reproduce the above copyright notice,    |
| this list of conditions and the following disclaimer in the documentation    |
| and/or other materials provided with the distribution.                       |
|                                                                              |
| Neither the name of Yang JiXian nor the names of its contributors may        |
| be used to endorse or promote products derived from this software without    |
| specific prior written permission.                                           |
|                                                                              |
| THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"  |
| AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE    |
| IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE   |
| ARE DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE FOR  |
| ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL       |
| DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR   |
| SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER   |
| CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT           |
| LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY    |
| OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH  |
| DAMAGE.                                                                      |
|==============================================================================|
| The Initial Developer of the Original Code is Yang JiXian (PRC).             |
| Portions created by Yang JiXian are Copyright (c)1999-2011.                  |
| All Rights Reserved.                                                         |
|==============================================================================|
| Contributor(s):                                                              |
|==============================================================================}

unit SynaSSockets;

{$IFDEF FPC}
{$MODE DELPHI}
{$ENDIF}

interface

uses
  Classes, SyncObjs, SysUtils, //{$IFNDEF LINUX}Windows, {$ENDIF}
  Blcksock, Synsock, Synautil, {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads, cmem, {$ENDIF}{$ENDIF}//{$IFDEF FPC}LclIntf, {$ENDIF} SynaIP,
  SSL_OpenSSL, SynaSockUtils;

type

  TSSocketServer = class;
  TCliThread = class;

  TSSocketClient = class(TCustomSocket)
  public
    LogonStyle: boolean;
    ORGID1, ORGID2: AnsiString;
    ClientFunctions, ClientPermTables, ClientReadTables, ClientSubFuncs,
      USRID: AnsiString;
    OrgStyle: integer;
    DisConnected: boolean;
    procedure Init;
  end;

  TOnDataAvailable = procedure(Sender: TObject; ClientThrd: TObject;
    FDSock: TSSocketClient; ReceiveData: string; Error: word) of object;
  TOnSockStatus = procedure(Sender: TObject; FSSock: TSSocketClient;
    Value: string) of object;
  TOnProgress = procedure(Sender: TObject; FSSock: TSSocketClient;
    FReason: THookSocketReason; Value: integer) of object;
  TOnConnectionChange = procedure(Sender: TObject; TCount: integer) of object;

  TSrvThread = class(TThread)
  private
    Sock: TSSocketClient;
  public
    FAOwner: TSSocketServer;
    TempThrd: TCliThread;
    constructor Create(aOwner: TSSocketServer);
    destructor Destroy; override;
    procedure Execute; override;
    procedure DoAddUser;
    procedure DoClearUsers;
  end;

  TCliThread = class(TThread)
  private
    Sock: TSSocketClient;
    CSock: TSocket;
  public
    FID: integer;
    FJob: TJobs;
    FHasLogon: boolean;
    UserName, UserID: AnsiString;
    FAOwner: TSSocketServer;
    FReceiveData, ResponseData: AnsiString;
    DisConnected: boolean;
    FTOnValue: AnsiString;
    FTOnReason: THookSocketReason;
    constructor Create(HSock: TSocket; aOwner: TSSocketServer);
    procedure Execute; override;
    procedure DoConnect;
    procedure DoOnConnectionChange;
    procedure DoOnDataAvailable;
    procedure DoAddUserCount;
    procedure DoSubUserCount;
    procedure SetSrvSSLFiles;
    procedure SockCallBack(Sender: TObject; Reason: THookSocketReason;
      const Value: string);
    procedure DoOnConnect;
    procedure DoOnDisConnect;
    procedure DoOnProgress;
  end;

  TSSocketServer = class(TComponent)
  private
    FHost: AnsiString;
    FPort: AnsiString;
    FThreadCount: integer;
    FWithSSL, FSSLverifyCert: boolean;
    FSSLCertCAFile, FSSLCertificateFile, FSSLPrivateKeyFile,
      FSSLKeyPassword, FSSLPFXfile: string;
  public
    FActive: boolean;
    ThrdList: TList;
    FOnResolvingBegin: TOnSockStatus;
    FOnResolvingEnd: TOnSockStatus;
    FOnSocketCreate: TOnSockStatus;
    FOnSocketClose: TOnSockStatus;
    FOnBind: TOnSockStatus;
    FOnConnect: TOnSockStatus;
    FOnCanRead: TOnSockStatus;
    FOnCanWrite: TOnSockStatus;
    FOnAccept: TOnSockStatus;
    FOnWait: TOnSockStatus;
    FOnSockError: TOnSockStatus;
    FOnDataAvailable: TOnDataAvailable;
    FOnProgress: TOnProgress;
    FOnConnectionChange: TOnConnectionChange;
    FCS: SyncObjs.TCriticalSection;
    FMaxSendBandwidth, FMaxRecvBandwidth: integer;
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
    procedure Listen;
    procedure Close;
    procedure DisConnectAll;
    procedure DisConnectID(TID: integer);
    procedure SendToAll(DataStr: AnsiString);
    procedure SendToClientID(TID: integer; DataStr: AnsiString);
    function Find(FXID: integer): integer;
  published
    property SSLPFXfile: string read FSSLPFXfile write FSSLPFXfile;
    property SSLCertCAFile: string read FSSLCertCAFile write FSSLCertCAFile;
    property SSLCertificateFile: string read FSSLCertificateFile write FSSLCertificateFile;
    property SSLPrivateKeyFile: string read FSSLPrivateKeyFile write FSSLPrivateKeyFile;
    property SSLKeyPassword: string read FSSLKeyPassword write FSSLKeyPassword;
    property SSLverifyCert: boolean read FSSLverifyCert write FSSLverifyCert;
    property WithSSL: boolean read FWithSSL write FWithSSL;
    property Port: AnsiString read FPort write FPort;
    property Host: AnsiString read FHost write FHost;
    property ConnectionCount: integer read FThreadCount;
    property MaxSendBandwidth: integer read FMaxSendBandwidth write FMaxSendBandwidth;
    property MaxRecvBandwidth: integer read FMaxRecvBandwidth write FMaxRecvBandwidth;
    property OnProgress: TOnProgress read FOnProgress write FOnProgress;
    property OnResolvingBegin: TOnSockStatus
      read FOnResolvingBegin write FOnResolvingBegin;
    property OnResolvingEnd: TOnSockStatus read FOnResolvingEnd write FOnResolvingEnd;
    property OnSocketCreate: TOnSockStatus read FOnSocketCreate write FOnSocketCreate;
    property OnSocketClose: TOnSockStatus read FOnSocketClose write FOnSocketClose;
    property OnBind: TOnSockStatus read FOnBind write FOnBind;
    property OnConnect: TOnSockStatus read FOnConnect write FOnConnect;
    property OnCanRead: TOnSockStatus read FOnCanRead write FOnCanRead;
    property OnCanWrite: TOnSockStatus read FOnCanWrite write FOnCanWrite;
    property OnAccept: TOnSockStatus read FOnAccept write FOnAccept;
    property OnWait: TOnSockStatus read FOnWait write FOnWait;
    property OnSockError: TOnSockStatus read FOnSockError write FOnSockError;
    property OnDataAvailable: TOnDataAvailable
      read FOnDataAvailable write FOnDataAvailable;
    property OnConnectionChange: TOnConnectionChange
      read FOnConnectionChange write FOnConnectionChange;
  end;

implementation

{==============================================================================}

procedure TSSocketClient.Init;
begin
  LogonStyle := False;
  ORGID1 := '';
  ORGID2 := '';
  ClientFunctions := '';
  ClientPermTables := '';
  ClientReadTables := '';
  USRID := '';
  OrgStyle := 0;
  DisConnected := False;
end;

constructor TSrvThread.Create(aOwner: TSSocketServer);
begin
  FAOwner := aOwner;
  inherited Create(False);
  Sock := TSSocketClient.Create;
  FreeOnTerminate := True;
end;

destructor TSrvThread.Destroy;
begin
  Sock.Free;
  inherited Destroy;
end;

procedure TSrvThread.DoAddUser;
begin
  FAOwner.ThrdList.Add(TempThrd);
end;

procedure TSrvThread.DoClearUsers;
begin
  FAOwner.ThrdList.Clear;
end;

procedure TSrvThread.Execute;
var
  ClientSock: TSocket;
  SID: integer;
begin
  with Sock do
  begin
    CreateSocket;
    SetLinger(True, 10);
    Bind('0.0.0.0', FAOwner.FPort);
    listen;
    if LastError <> 0 then
      Exit;
    SynChronize(DoClearUsers);
    SID := 0;
    repeat
      if Terminated then
        Break;
      if CanRead(1600) then
      begin
        ClientSock := accept;
        if LastError = 0 then
        begin
          TempThrd := TCliThread.Create(ClientSock, FAOwner);
          TempThrd.DisConnected := False;
          Inc(SID);
          TempThrd.FID := SID;
          SynChronize(DoAddUser);
        end;
      end;
    until False;
  end;
end;

constructor TCliThread.Create(HSock: TSocket; aOwner: TSSocketServer);
begin
  inherited Create(False);
  CSock := HSock;
  FAOwner := aOwner;
  FreeOnTerminate := True;
  FHasLogon := False;
end;

procedure TCliThread.DoAddUserCount;
begin
  Inc(FAOwner.FThreadCount);
end;

procedure TCliThread.SetSrvSSLFiles;
begin
  Sock.SSL.SSLType := LT_ALL;
  Sock.SSL.PFXfile := FAOwner.FSSLPFXfile;
  Sock.SSL.CertCAFile := FAOwner.FSSLCertCAFile;
  Sock.SSL.CertificateFile := FAOwner.FSSLCertificateFile;
  Sock.SSL.PrivateKeyFile := FAOwner.FSSLPrivateKeyFile;
  Sock.SSL.KeyPassword := FAOwner.FSSLKeyPassword;
  Sock.SSL.verifyCert := FAOwner.FSSLverifyCert;
end;

procedure TCliThread.DoSubUserCount;
begin
  Dec(FAOwner.FThreadCount);
end;

procedure TCliThread.Execute;
var
  s: AnsiString;
begin
  Synchronize(DoAddUserCount);
  Synchronize(DoOnConnectionChange);
  Sock := TSSocketClient.Create;
  Sock.OnStatus := SockCallBack;
  Sock.Init;
  try
    Sock.Socket := CSock;
    Sock.GetSins;
    Sock.MaxSendBandwidth := FAOwner.FMaxSendBandwidth;
    Sock.MaxRecvBandwidth := FAOwner.FMaxRecvBandwidth;
    Synchronize(DoConnect);
    Synchronize(SetSrvSSLFiles);
    if FAOwner.WithSSL then
    begin

      try
        if (not Sock.SSLAcceptConnection) or
          (Sock.SSL.LastError <> 0) then
        begin
          Sock.Free;
          Exit;
        end;
      except
        Sock.Free;
        Exit;
      end;
    end;

    with sock do
    begin
      repeat
        if terminated then
          Break;
        if FJob.Job = doSend then
        begin
          Sock.SendString(FJob.Data);
          FJob.Job := doNone;
        end;

        if CanRead(120) then
          s := RecvOnlineData(16000);

        if LastError <> 0 then
          Break;

        if s <> '' then
        begin
          FReceiveData := s;
          ResponseData := '';
          try
            Synchronize(DoOnDataAvailable);
          except
            DisConnected := True;
          end;
          s := '';
          try
            if ResponseData <> '' then
              Sock.SendOnlineData(ResponseData);
          except
          end;
        end;
        if LastError <> 0 then
          Break;
      until (DisConnected = True) or (Sock.DisConnected = True);
      FAOwner.DisConnectID(FID);
    end;
  finally
    if FAOwner.WithSSL then
      Sock.SSLDoShutdown;
    Sock.Free;
  end;
  Synchronize(DoSubUserCount);
  Synchronize(DoOnConnectionChange);
end;

procedure TCliThread.DoConnect;
begin
  if Assigned(FAOwner.OnConnect) then
    FAOwner.OnConnect(FAOwner, Sock, IntToStr(Sock.LastError));
end;

procedure TCliThread.DoOnConnectionChange;
begin
  if Assigned(FAOwner.FOnConnectionChange) then
    FAOwner.FOnConnectionChange(FAOwner, FAOwner.FThreadCount);
end;

procedure TCliThread.DoOnDataAvailable;
begin
  if Assigned(FAOwner.FOnDataAvailable) then
    FAOwner.FOnDataAvailable(FAOwner, Self, Sock, FReceiveData, Sock.LastError);
end;

procedure TCliThread.DoOnConnect;
begin
  FAOwner.FOnConnect(FAOwner, Sock, FTOnValue);
end;

procedure TCliThread.DoOnDisConnect;
begin
  FAOwner.FOnSocketClose(FAOwner, Sock, FTOnValue);
end;

procedure TCliThread.DoOnProgress;
begin
  FAOwner.FOnProgress(FAOwner, Sock, FTOnReason, StrToIntDef(FTOnValue, 0));
end;

procedure TCliThread.SockCallBack(Sender: TObject; Reason: THookSocketReason;
  const Value: string);
begin
  if not terminated then
  try
    FTOnReason := Reason;
    FTOnVaLUE := Value;
    if Assigned(FAOwner.FOnProgress) then
      SynChronize(DoOnProgress);
    case Reason of
      HR_ResolvingBegin:
        if Assigned(FAOwner.FOnResolvingBegin) then
          FAOwner.FOnResolvingBegin(FAOwner, Sock, Value);
      HR_ResolvingEnd:
        if Assigned(FAOwner.FOnResolvingEnd) then
          FAOwner.FOnResolvingEnd(FAOwner, Sock, Value);
      HR_SocketCreate:
        if Assigned(FAOwner.FOnSocketCreate) then
          FAOwner.FOnSocketCreate(FAOwner, Sock, Value);
      HR_SocketClose:
        begin
          if Assigned(FAOwner.FOnSocketClose) then
            SynChronize(DoOnDisConnect);
          Terminate;
        end;
      HR_Bind:
        if Assigned(FAOwner.FOnBind) then
          FAOwner.FOnBind(FAOwner, Sock, Value);
      HR_Connect:
        if Assigned(FAOwner.FOnConnect) then
          SynChronize(DoOnConnect);
      HR_CanRead:
        if Assigned(FAOwner.FOnCanRead) then
          FAOwner.FOnCanRead(FAOwner, Sock, Value);
      HR_CanWrite:
        if Assigned(FAOwner.FOnCanWrite) then
          FAOwner.FOnCanWrite(FAOwner, Sock, Value);
      HR_Accept:
        if Assigned(FAOwner.FOnAccept) then
          FAOwner.FOnAccept(FAOwner, Sock, Value);
      HR_Wait:
        if Assigned(FAOwner.FOnWait) then
          FAOwner.FOnWait(FAOwner, Sock, Value);
      HR_Error:
        if Assigned(FAOwner.FOnSockError) then
          FAOwner.FOnSockError(FAOwner, Sock, Value);
    end;
  except
  end;
end;

constructor TSSocketServer.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  FHost := '0.0.0.0';
  FPort := '9066';
  FCS := SyncObjs.TCriticalSection.Create;
  ThrdList := TList.Create;
  FMaxSendBandwidth := 0;
  FMaxRecvBandwidth := 0;
  FThreadCount := 0;
  WithSSL := false;
end;

procedure TSSocketServer.DisConnectAll;
var
  i: integer;
begin
  for i := 0 to ThrdList.Count - 1 do
  begin
    FCS.Enter;
    try
      TCliThread(ThrdList[i]).DisConnected := True;
    except
    end;
    FCS.Leave;
  end;
end;

procedure TSSocketServer.DisConnectID(TID: integer);
var
  i: integer;
begin
  i := Find(TID);
  if i = -1 then
    Exit;
  try
    TCliThread(ThrdList[i]).DisConnected := True;
    TCliThread(ThrdList[i]).Sock.CloseSocket;
    ThrdList.Delete(i);
  except
  end;
end;

procedure TSSocketServer.SendToAll(DataStr: AnsiString);
var
  i: integer;
begin
  FCS.Enter;
  for i := 0 to ThrdList.Count - 1 do
  begin
    try
      SendToClientID(TCliThread(ThrdList[i]).FID, DataStr);
    except
    end;
  end;
  FCS.Leave;
end;

function TSSocketServer.Find(FXID: integer): integer;
var
  l, h, i: integer;
begin
  Result := -1;
  l := 0;
  h := ThrdList.Count - 1;

  while l <= h do
  begin
    i := (l + h) shr 1;
    if TCliThread(ThrdList[i]).FID < FXID then
      l := l + 1
    else
      h := i - 1;

    if TCliThread(ThrdList[i]).FID = FXID then
    begin
      Result := i;
      break;
    end;
  end;
end;

procedure TSSocketServer.SendToClientID(TID: integer; DataStr: AnsiString);
var
  i: integer;
begin
  FCS.Enter;

  i := Find(TID);
  TCliThread(ThrdList[i]).FJob.Job := doSend;
  TCliThread(ThrdList[i]).FJob.Data := DataStr;
  FCS.Leave;
end;

destructor TSSocketServer.Destroy;
begin
  DisConnectAll;
  ThrdList.Free;
  FCS.Free;
  inherited Destroy;
end;

procedure TSSocketServer.Listen;
begin
  TSrvThread.Create(Self);
  FActive := True;
end;

procedure TSSocketServer.Close;
begin
  DisConnectAll;
  FActive := False;
end;

end.


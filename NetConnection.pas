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

unit NetConnection;

{$IFDEF FPC}
{$MODE Delphi}
{$ENDIF}

interface

uses
  Variants, {$IFDEF LCL} LCLIntf, LCLType, LMessages, {$ELSE} Windows,{$ENDIF}
  Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, DB,
  SynaCSockets, ClientProc, DataProcUtils;

type
  TOnlineConnection = class(TCSocket)
  public
    ConnectError: integer;
    Buffer: TClientConnBuffer;
    FUsrName, FPSW: TNetProcString;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Open;
    function Logon: Boolean;
    function Logon2: TLogonStyle;
  published
    property UserName: TNetProcString read FUsrName write FUsrName;
    property Password: TNetProcString read FPSW write FPSW;
  end;

implementation

{ TOnlineConnection }

constructor TOnlineConnection.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Buffer := TClientConnBuffer.Create(self);
  Port := '8080';
  Host := '127.0.0.1';
  Buffer.FSocket := Self;
end;

destructor TOnlineConnection.Destroy;
begin
  Buffer.Free;
  inherited Destroy;
end;

procedure TOnlineConnection.Open;
begin
  inherited Connect;
end;

function TOnlineConnection.Logon: Boolean;
begin
  if not FActive then
    Open;
  Result := Buffer.LogOnServer(FUsrName, FPSW);
end;

function TOnlineConnection.Logon2: TLogonStyle;
begin
  if not FActive then
    Open;
  Result := Buffer.LogOnServer2(FUsrName, FPSW);
end;

end.


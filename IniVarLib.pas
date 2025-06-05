unit IniVarLib;

interface

uses IniFiles, variants;

//����������
type

  TIniVarType = (stInt, stFloat, stString, stDateTime, stDate, stTime, stBoolean);

 /// <summary>
 /// ��Ini�ļ��ĺ���
 /// </summary>
 /// <param name="FileName">Ini�ļ���</param>
 /// <param name="Section">�ڵ�</param>
 /// <param name="Name">�ֶ���</param>
 /// <param name="xDataType">����������</param>
 /// <param name="DefaultValue">Ĭ��ֵ</param>
 /// <returns>���ر�������</returns>

function ReadIniValue(const FileName, Section, Name: string;
  xDataType: TIniVarType; DefaultValue: variant): variant;
procedure WriteIniValue(const FileName, Section, Name: string;
  Value: variant; xDataType: TIniVarType);

implementation

function ReadIniValue(const FileName, Section, Name: string;
  xDataType: TIniVarType; DefaultValue: variant): variant;
begin
  try
    with TIniFile.Create(FileName) do
    try
      if xDataType = stString then
        Result := ReadString(Section, Name, DefaultValue)
      else if xDataType = stInt then
        Result := ReadInteger(Section, Name, DefaultValue)
      else if xDataType = stFloat then
        Result := ReadFloat(Section, Name, DefaultValue)
      else if xDataType = stDateTime then
        Result := ReadDateTime(Section, Name, DefaultValue)
      else if xDataType = stDate then
        Result := ReadDate(Section, Name, DefaultValue)
      else if xDataType = stTime then
        Result := ReadTime(Section, Name, DefaultValue)
      else if xDataType = stBoolean then
        Result := ReadBool(Section, Name, DefaultValue);
    finally
      Free;
    end;
  except
  end;
end;

 /// <summary>
 /// дINI�ļ��ĺ���
 /// </summary>
 /// <param name="FileName">ini�ļ���</param>
 /// <param name="Section">�ڵ���</param>
 /// <param name="Name">�ֶ���</param>
 /// <param name="Value">�ֶ�ֵ</param>
 /// <param name="xDataType">������</param>

procedure WriteIniValue(const FileName, Section, Name: string;
  Value: variant; xDataType: TIniVarType);
begin
  try
    with TIniFile.Create(FileName) do
    try
      if xDataType = stString then
        WriteString(Section, Name, VarToStr(Value))
      else if xDataType = stInt then
        WriteInteger(Section, Name, Value)
      else if xDataType = stFloat then
        WriteFloat(Section, Name, Value)
      else if xDataType = stDateTime then
        WriteDateTime(Section, Name, VarToDateTime(Value))
      else if xDataType = stDate then
        WriteDate(Section, Name, VarToDateTime(Value))
      else if xDataType = stTime then
        WriteTime(Section, Name, VarToDateTime(Value))
      else if xDataType = stBoolean then
        WriteBool(Section, Name, Value);
    finally
      Free;
    end;
  except
  end;
end;

end.


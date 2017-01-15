unit uSList;

interface

uses
  SysUtils, Types, uSExpression, uSPair;

type
  TSList = class(TSPair)
  private
    FFunction: TSExpression;
    FArguments: TArray<TSExpression>;
    function GetFunctionName(): string;
    constructor CreateActual(Text: string);
    destructor Destroy();
    procedure InitFunctionAndArguments();
    procedure CheckFunctionNameAndArgumentsNumber(const AFunctionName: string;
      const ArgumentsNumber: Integer);
    function FunctionNameIsRegistered(const AFunctionName: string): Boolean;
    function GetArgumentsNumberForRegisteredFunction(const AFunctionName: string): Integer;
    procedure FreeFunctionAndArguments;
  protected
    procedure InitHeadAndTail(const AText: string); override;
  public
    function TextAsPair(): string;
  public
    function Evaluate(): Variant; override;
  end;

implementation

constructor TSList.CreateActual(Text: string);
begin
  inherited CreateActual(Text);

  try
    InitFunctionAndArguments();
  except
    Free();
    raise;
  end;
end;

destructor TSList.Destroy();
begin
  FreeFunctionAndArguments();
  inherited;
end;

procedure TSList.InitFunctionAndArguments();
var
  Elements: TArray<string>;

  procedure InitFunction();
  begin
    CheckFunctionNameAndArgumentsNumber(Elements[0], Length(Elements) - 1);
    FFunction := TSExpression.CreateExp(Elements[0]);
  end;

  procedure InitArguments();
  var
    I: Integer;
  begin
    SetLength(FArguments, Length(Elements) - 1);
    for I := 0 to Length(FArguments) - 1 do
      FArguments[I] := TSExpression.CreateExp(Elements[I + 1]);
  end;
begin
  Elements := ToElements(Text);
  try
    InitFunction();
    InitArguments();
  finally
    SetLength(Elements, 0);
  end;
end;

procedure TSList.FreeFunctionAndArguments();
var
  Argument: TSExpression;
begin
  FFunction.Free();

  for Argument in FArguments do
    Argument.Free();
  SetLength(FArguments, 0);
end;

procedure TSList.InitHeadAndTail(const AText: string);
begin
  inherited InitHeadAndTail(TextAsPair());
end;

function TSList.TextAsPair(): string;
var
  Elements: TArray<string>;

  procedure CompileHeadAndTail();
  var
    Head: string;
    Tail: string;
  begin
    Head := Elements[0];
    Tail :=
      Char_OpeningParenthesis +
      string.Join(Char_Space, Elements, 1, Length(Elements)) +
      Char_ClosingParenthesis;

    Result :=
      Char_OpeningParenthesis +
      Head +
      Char_Space + Char_PairDelimiter + Char_Space +
      Tail +
      Char_ClosingParenthesis;
  end;
begin
  Elements := ToElements(Text);
  try
    CompileHeadAndTail();
  finally
    SetLength(Elements, 0);
  end;
end;

function TSList.Evaluate: Variant;
begin

end;

procedure TSList.CheckFunctionNameAndArgumentsNumber(const AFunctionName: string;
  const ArgumentsNumber: Integer);
var
  RegisteredArgumentsNumber: Integer;
begin
  if not FunctionNameIsRegistered(AFunctionName) then
    RaiseException('Function is not defined: ' + AFunctionName);

  if ArgumentsNumber <> GetArgumentsNumberForRegisteredFunction(AFunctionName) then
    RaiseException(
      Format(
        'Function is called with wrong number of arguments:'#13#10 +
        '%s registered with %d arguments, called with %d arguments',
        [AFunctionName, RegisteredArgumentsNumber, ArgumentsNumber]
      )
    );
end;

function TSList.FunctionNameIsRegistered(const AFunctionName: string): Boolean;
begin
  Result := False;
end;

function TSList.GetArgumentsNumberForRegisteredFunction(const AFunctionName: string): Integer;
begin
  Result := 0;
end;

function TSList.GetFunctionName(): string;
begin
  Result := FFunction.Text;
end;

end.

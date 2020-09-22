{****************************************************}
{                                                    }
{  CodeBindings                                      }
{                                                    }
{  Copyright (C) 2020 Lachlan Gemmell                }
{                                                    }
{  http://www.tcontinuity.com.au                     }
{                                                    }
{****************************************************}
{                                                    }
{  This Source Code Form is subject to the terms of  }
{  the Mozilla Public License, v. 2.0. If a copy of  }
{  the MPL was not distributed with this file, You   }
{  can obtain one at                                 }
{                                                    }
{  http://mozilla.org/MPL/2.0/                       }
{                                                    }
{****************************************************}

unit uCodeBindings;

interface

{$REGION 'uses'}
uses
  System.SysUtils
  , System.Types
  , System.Classes
  , System.Rtti
  , System.Generics.Collections
  { mandatory LiveBindings related }
  , Data.DB
  , Data.Bind.DBScope
  , Data.Bind.Components
  , System.Bindings.Outputs
  { extensions for LiveBindings }
  , Data.Bind.EngExt
  , Fmx.Bind.DBEngExt
  , Fmx.Bind.Editors
  { control specific units }
  , FMX.Controls
  , FMX.StdCtrls
  , FMX.Edit
  , FMX.Memo
  , FMX.DateTimeCtrls
  , FMX.ListBox
  , Data.Bind.Grid
  , Fmx.Bind.Grid
  , FMX.Grid
  , FMX.ListView
  , FMX.ListView.Appearances
  , FMX.ListView.DynamicAppearance
  , Fmx.Bind.Navigator
  , FMX.ActnList
  ;
{$ENDREGION}

type
  TCodeBindingAfterSaveValueEvent = reference to procedure(const inControl : TComponent; const inField: TField);

  ICodeBinding = interface
    ['{B6153A75-D579-4591-950E-A01CD7B3CBAA}']
    function Identifier : string;

    function DestObj : TObject;
    function DestObjMemberName : string;
    procedure DoBeforeDestChanged;
    procedure DoAfterDestChanged;
    function LastKnownDestObj : TObject;

    function GetActive : boolean;
    procedure SetActive(inValue : boolean);
    property Active : boolean read GetActive write SetActive;

    function GetOnAfterSaveValue : TCodeBindingAfterSaveValueEvent;
    procedure SetOnAfterSaveValue(const inEventProc : TCodeBindingAfterSaveValueEvent);
    property OnAfterSaveValue : TCodeBindingAfterSaveValueEvent read GetOnAfterSaveValue write SetOnAfterSaveValue;
  end;

  TCodeBindings = class(TObject)
  type
    TFieldArray = array of TField;
    TCodeBindingsList = TList<ICodeBinding>;

  {$REGION 'TCodeBindings.TSession'}
  private type
    TSession = class(TComponent)
    { TCodeBindings.TSession.BindingsFor }
    strict private
      FBindingsFor : TObjectDictionary<TObject, TCodeBindingsList>;
      procedure Add(const inBinding : ICodeBinding);
    private
      procedure Remove(const inBinding : ICodeBinding; inRaiseExceptionIfNotFound : boolean);
    private
      procedure NotifyActiveStatusChanged(const inBinding : ICodeBinding);
      procedure NotifyBeforeDestChanged(const inBinding : ICodeBinding);
      procedure NotifyAfterDestChanged(const inBinding : ICodeBinding);
      procedure NotifyBeforeBindingDestroyed(const inBinding : ICodeBinding);
    public
      function BindingsFor(const inDestObj : TObject) : TCodeBindingsList;
    { TCodeBindings.TSession.BindingsList }
    strict private
      FBindingsList : TBindingsList;
    public
      property BindingsList : TBindingsList read FBindingsList;
    { TCodeBindings.TSession.BindSourceDBs }
    protected
      procedure Notification(inComponent: TComponent; inOperation: TOperation); override;
    strict private
      FBindSourceDBs : TObjectDictionary<TDataSet, TBindSourceDB>;
      function GetBindSourceDB(const inDataSet : TDataSet) : TBindSourceDB;
    public
      property BindSourceDBs[const inDataSet : TDataSet] : TBindSourceDB read GetBindSourceDB;
    { Event handlers for bindings }
    private
      procedure BindingAssignedValue(Sender: TObject; AssignValueRec: TBindingAssignValueRec; const Value: TValue);
    { TCodeBindings.TSession constructors/destructors }
    public
      constructor Create(inOwner : TComponent); override;
      destructor Destroy; override;
    end;
  strict protected
    class var CGlobal : TSession;
  {$ENDREGION}

  {$REGION 'Bindings'}
  strict private type
    TcbLinkControlToField = class(TLinkControlToField, ICodeBinding)
    strict private
      FSession : TSession;
    private
      FLastKnownDestObj : TObject;
    strict private
      function Identifier : string;
      function DestObj : TObject;
      function DestObjMemberName : string;
      procedure DoBeforeDestChanged;
      procedure DoAfterDestChanged;
      function LastKnownDestObj : TObject;
    strict private
      FAfterSaveValueEvent : TCodeBindingAfterSaveValueEvent;
    strict private
      function GetOnAfterSaveValue : TCodeBindingAfterSaveValueEvent;
      procedure SetOnAfterSaveValue(const inEventProc : TCodeBindingAfterSaveValueEvent);
    protected
      procedure Activated(Sender: TComponent); override;
    public
      constructor Create(inOwner : TComponent; inSession : TCodeBindings.TSession); reintroduce;
      destructor Destroy; override;
    end;

    TcbLinkPropertyToField = class(TLinkPropertyToField, ICodeBinding)
    strict private
      FSession : TCodeBindings.TSession;
    private
      FLastKnownDestObj : TObject;
    strict private
      function Identifier : string;
      function DestObj : TObject;
      function DestObjMemberName : string;
      procedure DoBeforeDestChanged;
      procedure DoAfterDestChanged;
      function LastKnownDestObj : TObject;
    strict private
      FAfterSaveValueEvent : TCodeBindingAfterSaveValueEvent;
    strict private
      function GetOnAfterSaveValue : TCodeBindingAfterSaveValueEvent;
      procedure SetOnAfterSaveValue(const inEventProc : TCodeBindingAfterSaveValueEvent);
    protected
      procedure Activated(Sender: TComponent); override;
    public
      constructor Create(inOwner : TComponent; inSession : TCodeBindings.TSession); reintroduce;
      destructor Destroy; override;
    end;

    TcbBindLink = class(TBindLink, ICodeBinding)
    strict private
      FSession : TCodeBindings.TSession;
    private
      FLastKnownDestObj : TObject;
    strict private
      function Identifier : string;
      function DestObj : TObject;
      function DestObjMemberName : string;
      procedure DoBeforeDestChanged;
      procedure DoAfterDestChanged;
      function LastKnownDestObj : TObject;
    strict private
      FAfterSaveValueEvent : TCodeBindingAfterSaveValueEvent;
    strict private
      function GetOnAfterSaveValue : TCodeBindingAfterSaveValueEvent;
      procedure SetOnAfterSaveValue(const inEventProc : TCodeBindingAfterSaveValueEvent);
    protected
      procedure DoOnActivated; override;
    public
      constructor Create(inOwner : TComponent; inSession : TCodeBindings.TSession); reintroduce;
      destructor Destroy; override;
    end;

    TcbLinkFillControlToField = class(TLinkFillControlToField, ICodeBinding)
    strict private
      FSession : TCodeBindings.TSession;
    private
      FLastKnownDestObj : TObject;
    strict private
      function Identifier : string;
      function DestObj : TObject;
      function DestObjMemberName : string;
      procedure DoBeforeDestChanged;
      procedure DoAfterDestChanged;
      function LastKnownDestObj : TObject;
    strict private
      FAfterSaveValueEvent : TCodeBindingAfterSaveValueEvent;
    strict private
      function GetOnAfterSaveValue : TCodeBindingAfterSaveValueEvent;
      procedure SetOnAfterSaveValue(const inEventProc : TCodeBindingAfterSaveValueEvent);
    protected
      procedure Activated(Sender: TComponent); override;
    public
      constructor Create(inOwner : TComponent; inSession : TCodeBindings.TSession); reintroduce;
      destructor Destroy; override;
    end;

    TcbLinkListControlToField = class(TLinkListControlToField, ICodeBinding)
    strict private
      FSession : TCodeBindings.TSession;
    private
      FLastKnownDestObj : TObject;
    strict private
      function Identifier : string;
      function DestObj : TObject;
      function DestObjMemberName : string;
      procedure DoBeforeDestChanged;
      procedure DoAfterDestChanged;
      function LastKnownDestObj : TObject;
    strict private
      FAfterSaveValueEvent : TCodeBindingAfterSaveValueEvent;
    strict private
      function GetOnAfterSaveValue : TCodeBindingAfterSaveValueEvent;
      procedure SetOnAfterSaveValue(const inEventProc : TCodeBindingAfterSaveValueEvent);
    protected
      procedure Activated(Sender: TComponent); override;
    public
      constructor Create(inOwner : TComponent; inSession : TCodeBindings.TSession); reintroduce;
      destructor Destroy; override;
    end;

    TcbLinkGridToDataSource = class(TLinkGridToDataSource, ICodeBinding)
    strict private
      { inherited SetActive uses a const parameter and so
      does not match ICodeBinding interface method signature }
      procedure CodeBindingSetActive(inValue : boolean);
      procedure ICodeBinding.SetActive = CodeBindingSetActive;
    {$REGION 'Overridden methods as placeholders for unimplemented virtual abstract methods'}
    protected
      procedure Reactivate; override;
      function RequiresControlHandler: Boolean; override;
    {$ENDREGION}
    strict private
      FSession : TCodeBindings.TSession;
    private
      FLastKnownDestObj : TObject;
    strict private
      function Identifier : string;
      function DestObj : TObject;
      function DestObjMemberName : string;
      procedure DoBeforeDestChanged;
      procedure DoAfterDestChanged;
      function LastKnownDestObj : TObject;
    strict private
      FAfterSaveValueEvent : TCodeBindingAfterSaveValueEvent;
    strict private
      function GetOnAfterSaveValue : TCodeBindingAfterSaveValueEvent;
      procedure SetOnAfterSaveValue(const inEventProc : TCodeBindingAfterSaveValueEvent);
    protected
      { GenerateExpressions used as Activated is never called }
      procedure GenerateExpressions(Sender: TComponent); override;
      procedure Activated(Sender: TComponent); override;
    public
      constructor Create(inOwner : TComponent; inSession : TCodeBindings.TSession); reintroduce;
      destructor Destroy; override;
    end;
  {$ENDREGION}

  {$REGION 'TCodeBindings.Add() overloads for control varieties bound to datasets'}
  strict private
    class function ArrayOfFields(inDataSet : TDataSet; const inFieldNames : array of string) : TFieldArray;
  strict protected
    class function DoBindSimpleControl(inControl: TControl; inDataField: TField; inActivate : boolean): TLinkControlToField;
  public
    class function Add(inEdit: TEdit; inDataField: TField; inActivate : boolean = True): TLinkControlToField; overload;
    class function Add(inMemo: TMemo; inDataField: TField; inActivate : boolean = True): TLinkControlToField; overload;
    class function Add(inDateEdit: TDateEdit; inDataField: TField; inActivate : boolean = True): TLinkControlToField; overload;
    class function Add(inCheckBox : TCheckBox; inDataField: TField; inActivate : boolean = True): TLinkControlToField; overload;
    class function Add(inLabel: TLabel; inDataField: TField; inActivate : boolean = True): TLinkPropertyToField; overload;
    class function Add(inLabel: TLabel; inDataSet : TDataSet; const inExpression : string; inActivate : boolean = True) : TBindLink; overload;
    class function Add(inComboBox : TComboBox; inDataField, inLookupDisplayField, inLookupValueField : TField; inActivate : boolean = True) : TLinkFillControlToField; overload;
    class function Add(inComboBox : TComboBox; inDataLookupField : TField; inActivate : boolean = True) : TLinkFillControlToField; overload;
    class procedure Add(ioNavigator : TBindNavigator; inDataSet : TDataSet); overload;
    class procedure Add(ioActionList : TActionList; inDataSet : TDataSet); overload;
    class procedure Add(ioActionList : TActionList; inDataSet : TDataSet; const inCategory : string); overload;
  public
    type
      TColumnSetupProc = reference to procedure(ioColumns : TLinkGridToDataSourceColumns);
  strict protected
    class function DoAdd(inGrid : TGrid; inDataSet : TDataSet; inUseAllFieldsIfEmpty : boolean; const inFields, inExcludeFields : array of TField; const inColumnSetupProc : TColumnSetupProc; inActivate : boolean) : TLinkGridToDataSource;
  public
    class function Add(inGrid : TGrid; inDataSet : TDataSet; const inFields, inExcludeFields : array of TField; const inColumnSetupProc : TColumnSetupProc; inActivate : boolean = True) : TLinkGridToDataSource; overload;
    class function Add(inGrid : TGrid; inDataSet : TDataSet; const inFieldNames, inExcludeFieldNames : array of string; const inColumnSetupProc : TColumnSetupProc; inActivate : boolean = True) : TLinkGridToDataSource; overload;
    class function Add(inGrid : TGrid; inDataSet : TDataSet; const inFields, inExcludeFields : array of TField; inActivate : boolean = True) : TLinkGridToDataSource; overload;
    class function Add(inGrid : TGrid; inDataSet : TDataSet; const inFieldNames, inExcludeFieldNames : array of string; inActivate : boolean = True) : TLinkGridToDataSource; overload;
    class function Add(inGrid : TGrid; inDataSet : TDataSet; const inColumnSetupProc : TColumnSetupProc; inActivate : boolean = True) : TLinkGridToDataSource; overload;
  public
    class function Add(inListView : TListView; inDisplayField : TField; inActivate : boolean = True) : TLinkListControlToField; overload;
    class function Add(inListView : TListView; inDisplayField, inDisplayDetailField : TField; inActivate : boolean = True) : TLinkListControlToField; overload;
    class function Add(inListView : TListView; const inDisplayFields : array of TField; inActivate : boolean = True) : TLinkListControlToField; overload;
  public
    class function AddBasic(inListBox : TListBox; inDisplayField : TField; inActivate : boolean = True) : TLinkListControlToField;
    class function Add(inListBox : TListBox; inDataField, inLookupDisplayField, inLookupValueField : TField; inActivate : boolean = True) : TLinkFillControlToField; overload;
    class function Add(inListBox : TListBox; inDataLookupField : TField; inActivate : boolean = True) : TLinkFillControlToField; overload;
  public
    class function Add(inListBoxItem: TListBoxItem; inDetailDataField: TField; inActivate : boolean = True): TLinkPropertyToField; overload;
  public
    class function Add(inComponent: TComponent; const inPropName : String; inDataField: TField; inActivate : boolean = True): TLinkPropertyToField; overload;
    class function Add(inComponent: TComponent; const inPropName : string; inDataSet : TDataSet; const inExpression : string; inActivate : boolean = True): TBindLink; overload;
  {$ENDREGION}

  public
    class procedure Remove(const inBinding : ICodeBinding);
    class procedure Release(var ioBinding : ICodeBinding);

  public
    class procedure DisableFor(const inDataSet : TDataSet);
    class procedure EnableFor(const inDataSet : TDataSet);

  public
    class function &For(const inComponent : TComponent) : TCodeBindingsList; overload;
    class function &For(const inComponent : TComponent; const inPropertyName : string) : ICodeBinding; overload;
    class function &For(const inDataSet : TDataSet) : TBindSourceDB; overload;
  public
    class constructor Create;
    class destructor Destroy;
  end;

  TLinkGridToDataSourceColumnsHelper = class helper for TLinkGridToDataSourceColumns
  private
    function DoAdd(const inFieldName : string; inWidth : integer) : TLinkGridToDataSourceColumn; overload;
  public
    function Add(inField : TField; inWidth : integer = -1) : TLinkGridToDataSourceColumn; overload;
    function Add(const inFieldName : string; inWidth : integer = -1) : TLinkGridToDataSourceColumn; overload;
  end;

  ECodeBindingsError = class(Exception);

implementation

const
  QUICKLINK_SUFFIX = 'QuickLink';

type
  TcbBindSourceDB = class(TBindSourceDB)
  strict private
    FDisableCount : integer;
  public
    procedure DisableDataSource;
    procedure EnableDataSource;
  public
    constructor Create(inDataSet : TDataSet); reintroduce;
  end;

  TcbDataSource = class(TSubDataSource)
  public
    procedure NotifyBindingsToRefreshData;
  end;

  TDataLink = class(Data.DB.TDataLink); { interposer hack }

procedure ClearProperty(ioObject : TObject; const inPropName : string);
var
  context : TRttiContext;
  instanceRTTI : TRttiInstanceType;
  propertyRTTI : TRttiInstanceProperty;
begin
  context := TRttiContext.Create;
  instanceRTTI := context.GetType(ioObject.ClassType) as TRttiInstanceType;
  propertyRTTI := instanceRTTI.GetProperty(inPropName) as TRttiInstanceProperty;
  propertyRTTI.SetValue(ioObject, TValue.Empty);
end;

{ TCodeBindings }

class constructor TCodeBindings.Create;
begin
  CGlobal := TSession.Create(nil);
end;

class destructor TCodeBindings.Destroy;
begin
  FreeAndNil(CGlobal);
end;

class function TCodeBindings.DoBindSimpleControl(inControl: TControl; inDataField: TField; inActivate : boolean): TLinkControlToField;
var
  bindSource : TBindSourceDB;
begin
  Result := TcbLinkControlToField.Create(inControl, CGlobal);
  Result.Name := 'Link' + inControl.Name;
  Result.Control := inControl;

  if Assigned(Result.Control) then
    (Result as TcbLinkControlToField).FLastKnownDestObj := Result.Control;

  bindSource := CGlobal.BindSourceDBs[inDataField.DataSet];
  Result.DataSource := bindSource;
  Result.FieldName := inDataField.FieldName;

  (Result as ICodeBinding).DoAfterDestChanged;

  Result.OnAssignedValue := CGlobal.BindingAssignedValue;

  Result.AutoActivate := inActivate;
  if inActivate and bindSource.DataSource.Enabled and inDataField.DataSet.Active then
    Result.Active := True;
end;

class function TCodeBindings.Add(inEdit: TEdit; inDataField: TField; inActivate: boolean): TLinkControlToField;
begin
  Result := DoBindSimpleControl(inEdit, inDataField, inActivate);
  if not Result.Active then
    inEdit.Text := string.Empty;
  inEdit.MaxLength := inDataField.Size;
end;

class function TCodeBindings.Add(inMemo: TMemo; inDataField: TField; inActivate: boolean): TLinkControlToField;
begin
  Result := DoBindSimpleControl(inMemo, inDataField, inActivate);
  if not Result.Active then
    inMemo.Lines.Clear;
end;

class function TCodeBindings.Add(inDateEdit: TDateEdit; inDataField: TField; inActivate: boolean): TLinkControlToField;
begin
  Result := DoBindSimpleControl(inDateEdit, inDataField, inActivate);
  if not Result.Active then
    inDateEdit.IsEmpty := True;
end;

class function TCodeBindings.Add(inCheckBox: TCheckBox; inDataField: TField; inActivate: boolean): TLinkControlToField;
begin
  Result := DoBindSimpleControl(inCheckBox, inDataField, inActivate);
  Result.Track := True;
  if not Result.Active then
    inCheckBox.IsChecked := False;
end;

class function TCodeBindings.Add(inComponent: TComponent; const inPropName : String; inDataField: TField; inActivate : boolean): TLinkPropertyToField;
var
  bindSource : TBindSourceDB;
begin
  Result := TcbLinkPropertyToField.Create(inComponent, CGlobal);
  Result.Name := 'Link' + inComponent.Name + InPropName.Replace('.','');
  Result.Component := inComponent;
  Result.ComponentProperty := inPropName;

  if Assigned(Result.Component) then
    (Result as TcbLinkPropertyToField).FLastKnownDestObj := Result.Component;

  bindSource := CGlobal.BindSourceDBs[inDataField.DataSet];
  Result.DataSource := bindSource;
  Result.FieldName := inDataField.FieldName;

  (Result as ICodeBinding).DoAfterDestChanged;

  Result.OnAssignedValue := CGlobal.BindingAssignedValue;

  Result.AutoActivate := inActivate;
  if inActivate and bindSource.DataSource.Enabled and inDataField.DataSet.Active then
    Result.Active := True;
end;

class function TCodeBindings.Add(inComponent: TComponent; const inPropName : string; inDataSet : TDataSet; const inExpression : string; inActivate : boolean): TBindLink;
var
  item : TExpressionItem;
  bindSource : TBindSourceDB;
begin
  Result := TcbBindLink.Create(inComponent, CGlobal);
  Result.Name := 'Link' + inComponent.Name + InPropName.Replace('.','');
  Result.ControlComponent := inComponent;

  if Assigned(Result.ControlComponent) then
    (Result as TcbBindLink).FLastKnownDestObj := Result.ControlComponent;

  bindSource := CGlobal.BindSourceDBs[inDataSet];
  Result.SourceComponent := bindSource;

  item := Result.FormatExpressions.AddExpression;
  item.ControlExpression := inPropName;
  item.SourceExpression := inExpression;

  item := Result.ClearExpressions.AddExpression;
  item.ControlExpression := inPropName;
  item.SourceExpression := 'nil';

  (Result as ICodeBinding).DoAfterDestChanged;

  Result.OnAssignedValue := CGlobal.BindingAssignedValue;

  Result.AutoActivate := inActivate;
  if inActivate and bindSource.DataSource.Enabled and inDataSet.Active then
    Result.Active := True
  else
    ClearProperty(inComponent, inPropName);
end;

class function TCodeBindings.Add(inListBoxItem: TListBoxItem; inDetailDataField: TField; inActivate : boolean): TLinkPropertyToField;
var
  bindSource : TBindSourceDB;
begin
  Result := TcbLinkPropertyToField.Create(inListBoxItem, CGlobal);
  Result.Name := 'Link' + inListBoxItem.Name;
  Result.Component := inListBoxItem;
  Result.ComponentProperty := 'ItemData.Detail';

  if Assigned(Result.Component) then
    (Result as TcbLinkPropertyToField).FLastKnownDestObj := Result.Component;

  bindSource := CGlobal.BindSourceDBs[inDetailDataField.DataSet];
  Result.DataSource := bindSource;
  Result.FieldName := inDetailDataField.FieldName;

  (Result as ICodeBinding).DoAfterDestChanged;

  Result.OnAssignedValue := CGlobal.BindingAssignedValue;

  Result.AutoActivate := inActivate;
  if inActivate and bindSource.DataSource.Enabled and inDetailDataField.DataSet.Active then
    Result.Active := True;
end;

class function TCodeBindings.Add(inLabel: TLabel; inDataField: TField; inActivate: boolean): TLinkPropertyToField;
var
  bindSource : TBindSourceDB;
begin
  Result := TcbLinkPropertyToField.Create(inLabel, CGlobal);
  Result.Name := 'Link' + inLabel.Name;
  Result.Component := inLabel;
  Result.ComponentProperty := 'Text';

  if Assigned(Result.Component) then
    (Result as TcbLinkPropertyToField).FLastKnownDestObj := Result.Component;

  bindSource := CGlobal.BindSourceDBs[inDataField.DataSet];
  Result.DataSource := bindSource;
  Result.FieldName := inDataField.FieldName;

  (Result as ICodeBinding).DoAfterDestChanged;

  Result.OnAssignedValue := CGlobal.BindingAssignedValue;

  Result.AutoActivate := inActivate;
  if inActivate and bindSource.DataSource.Enabled and inDataField.DataSet.Active then
    Result.Active := True
  else
    inLabel.Text := string.Empty;
end;

class function TCodeBindings.Add(inLabel: TLabel; inDataSet : TDataSet; const inExpression: string; inActivate: boolean): TBindLink;
var
  item : TExpressionItem;
  bindSource : TBindSourceDB;
begin
  Result := TcbBindLink.Create(inLabel, CGlobal);
  Result.Name := 'Link' + inLabel.Name;
  Result.ControlComponent := inLabel;

  if Assigned(Result.ControlComponent) then
    (Result as TcbBindLink).FLastKnownDestObj := Result.ControlComponent;

  bindSource := CGlobal.BindSourceDBs[inDataSet];
  Result.SourceComponent := bindSource;

  item := Result.FormatExpressions.AddExpression;
  item.ControlExpression := 'Text';
  item.SourceExpression := inExpression;

  item := Result.ClearExpressions.AddExpression;
  item.ControlExpression := 'Text';
  item.SourceExpression := 'nil';

  (Result as ICodeBinding).DoAfterDestChanged;

  Result.OnAssignedValue := CGlobal.BindingAssignedValue;

  Result.AutoActivate := inActivate;
  if inActivate and bindSource.DataSource.Enabled and inDataSet.Active then
    Result.Active := True
  else
    inLabel.Text := string.Empty;
end;

class function TCodeBindings.Add(inComboBox: TComboBox; inDataField, inLookupDisplayField, inLookupValueField: TField; inActivate: boolean): TLinkFillControlToField;
var
  bindSource : TBindSourceDB;
begin
  Result := TcbLinkFillControlToField.Create(inComboBox, CGlobal);
  Result.Name := 'Link' + inComboBox.Name;
  Result.Control := inComboBox;

  if Assigned(Result.Control) then
    (Result as TcbLinkFillControlToField).FLastKnownDestObj := Result.Control;

  bindSource := CGlobal.BindSourceDBs[inDataField.DataSet];
  Result.DataSource := bindSource;
  Result.FieldName := inDataField.FieldName;

  Result.FillDataSource := CGlobal.BindSourceDBs[inLookupDisplayField.DataSet];
  Result.FillDisplayFieldName := inLookupDisplayField.FieldName;
  Result.FillValueFieldName := inLookupValueField.FieldName;

  Result.AutoFill := True;
  Result.Track := True;

  (Result as ICodeBinding).DoAfterDestChanged;

  Result.OnAssignedValue := CGlobal.BindingAssignedValue;

  Result.AutoActivate := inActivate;
  if inActivate and bindSource.DataSource.Enabled and inDataField.DataSet.Active then
    Result.Active := True
  else
    inComboBox.Clear;
end;

class function TCodeBindings.Add(inComboBox: TComboBox; inDataLookupField : TField; inActivate: boolean): TLinkFillControlToField;
var
  dataField, lookupDisplayField, lookupValueField : TField;
  lookupDataSet : TDataSet;
begin
  {$REGION 'Assert'}Assert(inDataLookupField.FieldKind = fkLookup);{$ENDREGION}
  dataField := inDataLookupField.DataSet.FieldByName(inDataLookupField.KeyFields);
  lookupDataSet := inDataLookupField.LookupDataSet;
  lookupValueField := lookupDataSet.FieldByName(inDataLookupField.LookupKeyFields);
  lookupDisplayField := lookupDataSet.FieldByName(inDataLookupField.LookupResultField);
  Result := Add(inComboBox, dataField, lookupDisplayField, lookupValueField, inActivate);
end;

class function TCodeBindings.DoAdd(inGrid: TGrid; inDataSet: TDataSet; inUseAllFieldsIfEmpty : boolean; const inFields, inExcludeFields: array of TField; const inColumnSetupProc: TColumnSetupProc; inActivate: boolean): TLinkGridToDataSource;

  function ContainsField(inField : TField; const inFields : array of TField) : boolean;
  var
    f : integer;
  begin
    Result := False;
    for f := Low(inFields) to High(inFields) do
      if inFields[f] = inField then
        Exit(True);
  end;

var
  f : integer;
  bindSource : TBindSourceDB;
begin
  Result := TcbLinkGridToDataSource.Create(inGrid, CGlobal);
  Result.Name := 'Link' + inGrid.Name;
  Result.GridControl := inGrid;

  if Assigned(Result.GridControl) then
    (Result as TcbLinkGridToDataSource).FLastKnownDestObj := Result.GridControl;

  bindSource := CGlobal.BindSourceDBs[inDataSet];
  Result.DataSource := bindSource;

  if inUseAllFieldsIfEmpty and (Length(inFields) = 0) then begin
    for f := 0 to inDataSet.FieldCount - 1 do begin
      if not ContainsField(inDataSet.Fields[f], inExcludeFields) then
        Result.Columns.Add(inDataSet.Fields[f]);
    end;
  end
  else begin
    for f := Low(inFields) to High(inFields) do begin
      if not ContainsField(inFields[f], inExcludeFields) then
        Result.Columns.Add(inFields[f]);
    end;
  end;

  if Assigned(inColumnSetupProc) then
    inColumnSetupProc(Result.Columns);

  (Result as ICodeBinding).DoAfterDestChanged;

  Result.OnAssignedValue := CGlobal.BindingAssignedValue;

  Result.AutoActivate := inActivate;
  if inActivate and bindSource.DataSource.Enabled and inDataSet.Active then
    Result.Active := True
  else
    inGrid.ClearContent;
end;

class function TCodeBindings.Add(inGrid: TGrid; inDataSet: TDataSet; const inFields, inExcludeFields: array of TField; const inColumnSetupProc: TColumnSetupProc; inActivate: boolean): TLinkGridToDataSource;
begin
  Result := DoAdd(inGrid, inDataSet, True, inFields, inExcludeFields, inColumnSetupProc, inActivate);
end;

class function TCodeBindings.Add(inGrid: TGrid; inDataSet: TDataSet; const inColumnSetupProc: TColumnSetupProc; inActivate: boolean): TLinkGridToDataSource;
begin
  Result := DoAdd(inGrid, inDataSet, True, [], [], inColumnSetupProc, inActivate);
end;

class function TCodeBindings.Add(inGrid: TGrid; inDataSet: TDataSet; const inFields, inExcludeFields: array of TField; inActivate: boolean): TLinkGridToDataSource;
begin
  Result := DoAdd(inGrid, inDataSet, True, inFields, inExcludeFields, nil, inActivate);
end;

class function TCodeBindings.Add(inGrid: TGrid; inDataSet: TDataSet; const inFieldNames, inExcludeFieldNames: array of string; const inColumnSetupProc: TColumnSetupProc; inActivate: boolean): TLinkGridToDataSource;
var
  fields, excludeFields : TFieldArray;
begin
  fields := ArrayOfFields(inDataSet, inFieldNames);
  excludeFields := ArrayOfFields(inDataSet, inExcludeFieldNames);
  Result := DoAdd(inGrid, inDataSet, True, fields, excludeFields, inColumnSetupProc, inActivate);
end;

class function TCodeBindings.Add(inGrid: TGrid; inDataSet: TDataSet; const inFieldNames, inExcludeFieldNames: array of string; inActivate: boolean): TLinkGridToDataSource;
var
  fields, excludeFields : TFieldArray;
begin
  fields := ArrayOfFields(inDataSet, inFieldNames);
  excludeFields := ArrayOfFields(inDataSet, inExcludeFieldNames);
  Result := Add(inGrid, inDataSet, fields, excludeFields, nil, inActivate);
end;

class function TCodeBindings.ArrayOfFields(inDataSet : TDataSet; const inFieldNames : array of string) : TFieldArray;
var
  f : integer;
begin
  SetLength(Result, Length(inFieldNames));
  for f := Low(inFieldNames) to High(inFieldNames) do
    Result[f] := inDataSet.FieldByName(inFieldNames[f]);
end;

class function TCodeBindings.AddBasic(inListBox : TListBox; inDisplayField : TField; inActivate : boolean = True) : TLinkListControlToField;
var
  bindSource : TBindSourceDB;
begin
  Result := TcbLinkListControlToField.Create(inListBox, CGlobal);
  Result.Name := 'Link' + inListBox.Name;
  Result.Control := inListBox;

  if Assigned(Result.Control) then
    (Result as TcbLinkListControlToField).FLastKnownDestObj := Result.Control;

  bindSource := CGlobal.BindSourceDBs[inDisplayField.DataSet];
  Result.DataSource := bindSource;
  Result.FieldName := inDisplayField.FieldName;

  (Result as ICodeBinding).DoAfterDestChanged;

  Result.OnAssignedValue := CGlobal.BindingAssignedValue;

  Result.AutoActivate := inActivate;
  if inActivate and bindSource.DataSource.Enabled and inDisplayField.DataSet.Active then
    Result.Active := True;
end;

class function TCodeBindings.Add(inListBox: TListBox; inDataField, inLookupDisplayField, inLookupValueField: TField; inActivate: boolean): TLinkFillControlToField;
var
  bindSource : TBindSourceDB;
begin
  Result := TcbLinkFillControlToField.Create(inListBox, CGlobal);
  Result.Name := 'Link' + inListBox.Name;
  Result.Control := inListBox;

  if Assigned(Result.Control) then
    (Result as TcbLinkFillControlToField).FLastKnownDestObj := Result.Control;

  bindSource := CGlobal.BindSourceDBs[inDataField.DataSet];
  Result.DataSource := bindSource;
  Result.FieldName := inDataField.FieldName;

  Result.FillDataSource := CGlobal.BindSourceDBs[inLookupDisplayField.DataSet];
  Result.FillDisplayFieldName := inLookupDisplayField.FieldName;
  Result.FillValueFieldName := inLookupValueField.FieldName;

  Result.AutoFill := True;
  Result.Track := True;

  (Result as ICodeBinding).DoAfterDestChanged;

  Result.OnAssignedValue := CGlobal.BindingAssignedValue;

  Result.AutoActivate := inActivate;
  if inActivate and bindSource.DataSource.Enabled and inDataField.DataSet.Active then
    Result.Active := True
  else
    inListBox.ItemIndex := -1;
end;

class function TCodeBindings.Add(inListBox: TListBox; inDataLookupField : TField; inActivate: boolean): TLinkFillControlToField;
var
  dataField, lookupDisplayField, lookupValueField : TField;
  lookupDataSet : TDataSet;
begin
  {$REGION 'Assert'}Assert(inDataLookupField.FieldKind = fkLookup);{$ENDREGION}
  dataField := inDataLookupField.DataSet.FieldByName(inDataLookupField.KeyFields);
  lookupDataSet := inDataLookupField.LookupDataSet;
  lookupValueField := lookupDataSet.FieldByName(inDataLookupField.LookupKeyFields);
  lookupDisplayField := lookupDataSet.FieldByName(inDataLookupField.LookupResultField);
  Result := Add(inListBox, dataField, lookupDisplayField, lookupValueField, inActivate);
end;

class function TCodeBindings.Add(inListView: TListView; inDisplayField: TField; inActivate : boolean): TLinkListControlToField;
var
  bindSource : TBindSourceDB;
begin
  Result := TcbLinkListControlToField.Create(inListView, CGlobal);
  Result.Name := 'Link' + inListView.Name;
  Result.Control := inListView;

  if Assigned(Result.Control) then
    (Result as TcbLinkListControlToField).FLastKnownDestObj := Result.Control;

  bindSource := CGlobal.BindSourceDBs[inDisplayField.DataSet];
  Result.DataSource := bindSource;
  Result.FieldName := inDisplayField.FieldName;

  (Result as ICodeBinding).DoAfterDestChanged;

  Result.OnAssignedValue := CGlobal.BindingAssignedValue;

  Result.AutoActivate := inActivate;
  if inActivate and bindSource.DataSource.Enabled and inDisplayField.DataSet.Active then
    Result.Active := True;
end;

function FullyQualifiedComponentName(inComponent : TComponent) : string;
var
  component : TComponent;
begin
  Result := '';
  component := inComponent;
  repeat
    if Result.IsEmpty then
      Result := component.Name
    else
      Result := component.Name + Result;
    component := component.Owner;
  until (not Assigned (component));
end;

class function TCodeBindings.&For(const inComponent : TComponent): TCodeBindingsList;
begin
  Result := CGlobal.BindingsFor(inComponent);
end;

class function TCodeBindings.&For(const inComponent : TComponent; const inPropertyName : string): ICodeBinding;
var
  bindings : TCodeBindingsList;
begin
  bindings := &For(inComponent);
  { TODO 1 : Find the property }
  if bindings.Count = 1 then
    Result := bindings[0];
end;

class function TCodeBindings.&For(const inDataSet : TDataSet) : TBindSourceDB;
begin
  Result := CGlobal.BindSourceDBs[inDataSet];
end;

class procedure TCodeBindings.Remove(const inBinding: ICodeBinding);
begin
  CGlobal.Remove(inBinding, True);
end;

class procedure TCodeBindings.Release(var ioBinding: ICodeBinding);
begin
  Remove(ioBinding);
  ioBinding := nil;
end;

class function TCodeBindings.Add(inListView: TListView; inDisplayField, inDisplayDetailField: TField; inActivate : boolean): TLinkListControlToField;
var
  item : TFormatExpressionItem;
  bindSource : TBindSourceDB;
begin
  Result := TcbLinkListControlToField.Create(inListView, CGlobal);
  Result.Name := 'Link' + inListView.Name;
  Result.Control := inListView;

  if Assigned(Result.Control) then
    (Result as TcbLinkListControlToField).FLastKnownDestObj := Result.Control;

  bindSource := CGlobal.BindSourceDBs[inDisplayField.DataSet];
  Result.DataSource := bindSource;
  Result.FieldName := inDisplayField.FieldName;

  item := Result.FillExpressions.AddExpression;
  item.SourceMemberName := inDisplayDetailField.FieldName;
  item.ControlMemberName := 'Detail';

  (Result as ICodeBinding).DoAfterDestChanged;

  Result.OnAssignedValue := CGlobal.BindingAssignedValue;

  Result.AutoActivate := inActivate;
  if inActivate and bindSource.DataSource.Enabled and inDisplayField.DataSet.Active then
    Result.Active := True;
end;

class function TCodeBindings.Add(inListView : TListView; const inDisplayFields : array of TField; inActivate : boolean = True) : TLinkListControlToField;
var
  item : TFormatExpressionItem;
  f : integer;
  field : TField;
  dataSet : TDataSet;
  appearanceItems : TCollection;
  appearanceitem : TCommonObjectAppearance;
  bindSource : TBindSourceDB;
begin
  {$REGION 'Assert'}
  Assert(inListView.ItemAppearanceObjects.ItemObjects is TDynamicAppearance, inListView.Name + ' does not use a dynamic appearance');
  Assert(Length(inDisplayFields) > 0);
  {$ENDREGION}
  dataSet := inDisplayFields[0].DataSet;
  for field in inDisplayFields do
    {$REGION 'Assert'}Assert(field.DataSet = dataSet);{$ENDREGION}

  Result := TcbLinkListControlToField.Create(inListView, CGlobal);
  Result.Name := 'Link' + inListView.Name;
  Result.Control := inListView;

  if Assigned(Result.Control) then
    (Result as TcbLinkListControlToField).FLastKnownDestObj := Result.Control;

  bindSource := CGlobal.BindSourceDBs[dataSet];
  Result.DataSource := bindSource;

  appearanceItems := (inListView.ItemAppearanceObjects.ItemObjects as TDynamicAppearance).ObjectsCollection;
  {$REGION 'Assert'}Assert(appearanceItems.Count >= Length(inDisplayFields));{$ENDREGION}

  for f := Low(inDisplayFields) to High(inDisplayFields) do begin
    field := inDisplayFields[f];
    if Assigned(field) then begin
      appearanceItem := (appearanceItems.Items[f] as TAppearanceObjectItem).Appearance;
      item := Result.FillExpressions.AddExpression;
      item.SourceMemberName := field.FieldName;
      item.ControlMemberName := appearanceItem.Name;
    end;
  end;

  (Result as ICodeBinding).DoAfterDestChanged;

  Result.OnAssignedValue := CGlobal.BindingAssignedValue;

  Result.AutoActivate := inActivate;
  if inActivate and bindSource.DataSource.Enabled and dataSet.Active then
    Result.Active := True;
end;

class procedure TCodeBindings.Add(ioNavigator: TBindNavigator; inDataSet: TDataSet);
begin
  ioNavigator.DataSource := CGlobal.BindSourceDBs[inDataSet];
end;

class procedure TCodeBindings.Add(ioActionList : TActionList; inDataSet : TDataSet);
var
  bindSource : TBindSourceDB;
  a : integer;
begin
  bindSource := CGlobal.BindSourceDBs[inDataSet];

  for a := 0 to ioActionList.ActionCount - 1 do begin
    if ioActionList[a] is TFMXBindNavigateAction then
      TFMXBindNavigateAction(ioActionList[a]).DataSource := bindSource;
  end;
end;

class procedure TCodeBindings.Add(ioActionList : TActionList; inDataSet : TDataSet; const inCategory : string);
var
  action : TFMXBindNavigateAction;
  bindSource : TBindSourceDB;
  a : integer;
begin
  bindSource := CGlobal.BindSourceDBs[inDataSet];

  for a := 0 to ioActionList.ActionCount - 1 do begin
    if ioActionList[a] is TFMXBindNavigateAction then begin
      action := TFMXBindNavigateAction(ioActionList[a]);
      if action.Category = inCategory then
        action.DataSource := bindSource;
    end;
  end;
end;

class procedure TCodeBindings.DisableFor(const inDataSet: TDataSet);
begin
  (CGlobal.BindSourceDBs[inDataSet] as TcbBindSourceDB).DisableDataSource;
end;

class procedure TCodeBindings.EnableFor(const inDataSet: TDataSet);
begin
  (CGlobal.BindSourceDBs[inDataSet] as TcbBindSourceDB).EnableDataSource;
end;

{ TCodeBindings.TSession }

constructor TCodeBindings.TSession.Create(inOwner: TComponent);
begin
  inherited;
  FBindingsList := TBindingsList.Create(nil);
  FBindSourceDBs := TObjectDictionary<TDataSet, TBindSourceDB>.Create([doOwnsValues]);
  FBindingsFor := TObjectDictionary<TObject, TCodeBindingsList>.Create([doOwnsValues]);
end;

destructor TCodeBindings.TSession.Destroy;
begin
  {$REGION 'Assert'}
  Assert(FBindingsFor.Count = 0);
  Assert(FBindSourceDBs.Count = 0);
  {$ENDREGION}
  FreeAndNil(FBindingsFor);
  FreeAndNil(FBindSourceDBs);
  FreeAndNil(FBindingsList);
  inherited;
end;

function TCodeBindings.TSession.GetBindSourceDB(const inDataSet: TDataSet): TBindSourceDB;
begin
  if not FBindSourceDBs.TryGetValue(inDataSet, Result) then begin
    Result := TcbBindSourceDB.Create(inDataSet);
    FBindSourceDBs.Add(inDataSet, Result);
    inDataSet.FreeNotification(Self);
  end;
end;

procedure TCodeBindings.TSession.Add(const inBinding: ICodeBinding);
var
  bindings : TCodeBindingsList;
begin
  { get the existing bindings known by this identifier or create a new list }
  if FBindingsFor.TryGetValue(inBinding.DestObj, bindings) then begin
    if bindings.Contains(inBinding) then
      raise ECodeBindingsError.Create('Binding already in FBindingsFor');
  end
  else begin
    bindings := TCodeBindingsList.Create;
    FBindingsFor.Add(inBinding.DestObj, bindings);
  end;

  { add the new binding to the list of bindings for this identifier }
  bindings.Add(inBinding);
end;

procedure TCodeBindings.TSession.Remove(const inBinding: ICodeBinding; inRaiseExceptionIfNotFound : boolean);
var
  bindings : TCodeBindingsList;
  destObj : TObject;
begin
  destObj := inBinding.DestObj;
  if not Assigned(destObj) then
    destObj := inBinding.LastKnownDestObj;
  {$REGION 'Assert'}Assert(Assigned(destObj));{$ENDREGION}

  if not FBindingsFor.TryGetValue(destObj, bindings) and inRaiseExceptionIfNotFound then
    raise ECodeBindingsError.CreateFmt('No bindings found for %s', [inBinding.Identifier]);

  if Assigned(bindings) then begin
    bindings.Remove(inBinding);
    if bindings.Count = 0 then
      FBindingsFor.Remove(destObj)
  end;
end;

function TCodeBindings.TSession.BindingsFor(const inDestObj : TObject): TCodeBindingsList;
begin
  Result := FBindingsFor[inDestObj];
end;

procedure TCodeBindings.TSession.NotifyActiveStatusChanged(const inBinding: ICodeBinding);
begin
  { TODO : IMPLEMENT }
end;

procedure TCodeBindings.TSession.NotifyBeforeDestChanged(const inBinding: ICodeBinding);
begin
  Remove(inBinding, True);
end;

procedure TCodeBindings.TSession.NotifyAfterDestChanged(const inBinding: ICodeBinding);
begin
  Add(inBinding);
end;

procedure TCodeBindings.TSession.NotifyBeforeBindingDestroyed(const inBinding: ICodeBinding);
begin
  Remove(inBinding, False);
end;

procedure TCodeBindings.TSession.Notification(inComponent: TComponent; inOperation: TOperation);
begin
  inherited;
  if (inOperation = opRemove) and (inComponent is TDataSet) then
    FBindSourceDBs.Remove(TDataSet(inComponent));
end;

procedure TCodeBindings.TSession.BindingAssignedValue(Sender: TObject; AssignValueRec: TBindingAssignValueRec; const Value: TValue);
var
  bindings : TCodeBindingsList;
  binding : ICodeBinding;
  destControl : TComponent;
  sourceField : TField;
begin
  if Sender is TCommonBindComponent then
    destControl := TCommonBindComponent(Sender).ControlComponent
  else
    destControl := nil;

  if FBindingsFor.TryGetValue(destControl, bindings) then begin
    if AssignValueRec.OutObj is TField then begin
      sourceField := TField(AssignValueRec.OutObj);
      {$REGION 'Assert'}Assert(bindings.Count = 1, 'Multiple bindings not yet supported');{$ENDREGION}
      binding := bindings[0];
      if Assigned(binding.OnAfterSaveValue) then
        binding.OnAfterSaveValue(destControl, sourceField);
    end;
  end;
end;

{ TcbBindSourceDB }

constructor TcbBindSourceDB.Create(inDataSet: TDataSet);
begin
  inherited Create(nil);
  DataSource := TcbDataSource.Create(Self);
  DataSource.Name := 'CodeBindingsSubDataSource';
  DataSource.SetSubComponent(True);
  DataSource.DataSet := inDataSet;
end;

procedure TcbBindSourceDB.DisableDataSource;
begin
  Inc(FDisableCount);
  if DataSource.Enabled and (FDisableCount > 0) then begin
    DataSource.Enabled := False;
  end;
end;

procedure TcbBindSourceDB.EnableDataSource;
begin
  if FDisableCount > 0 then
    Dec(FDisableCount);
  if not DataSource.Enabled and (FDisableCount = 0) then begin
    DataSource.Enabled := True;
    (DataSource as TcbDataSource).NotifyBindingsToRefreshData;
  end;
end;

{ TcbDataSource }

procedure TcbDataSource.NotifyBindingsToRefreshData;
var
  i : integer;
begin
  { send the datalinks of the binding components a dataset event using the interposer hack }
  for i := 0 to DataLinks.Count - 1 do
    TDataLink(DataLinks[i]).DataEvent(deDataSetChange, 0);
end;

{ TLinkGridToDataSourceColumnsHelper }

function TLinkGridToDataSourceColumnsHelper.DoAdd(const inFieldName: string; inWidth: integer) : TLinkGridToDataSourceColumn;
begin
  Result := Self.Add;
  Result.MemberName := inFieldName;
  if inWidth >= 0 then
    Result.Width := inWidth;
end;

function TLinkGridToDataSourceColumnsHelper.Add(inField: TField; inWidth: integer) : TLinkGridToDataSourceColumn;
var
  width : integer;
begin
  if inWidth >= 0 then
    width := inWidth
  else begin
    case inField.DataType of
      ftString, ftWideString:
        width := inField.Size * 15;
    else
      width := -1;
    end;
  end;
  Result := DoAdd(inField.FieldName, width);
end;

function TLinkGridToDataSourceColumnsHelper.Add(const inFieldName: string; inWidth: integer) : TLinkGridToDataSourceColumn;
var
  field : TField;
begin
  field := ((Grid as ILinkGridToDataSource).DataSource as TBindSourceDB).DataSet.FindField(inFieldName);
  if Assigned(field) then
    Result := Add(field, inWidth)
  else
    Result := DoAdd(inFieldName, inWidth);
end;

{ TCodeBindings.TcbLinkGridToDataSource }

constructor TCodeBindings.TcbLinkGridToDataSource.Create(inOwner: TComponent; inSession: TCodeBindings.TSession);
begin
  inherited Create(inOwner);
  BindingsList := inSession.BindingsList;
  FSession := inSession;
end;

destructor TCodeBindings.TcbLinkGridToDataSource.Destroy;
begin
  FSession.NotifyBeforeBindingDestroyed(Self);
  inherited;
end;

function TCodeBindings.TcbLinkGridToDataSource.DestObj: TObject;
begin
  Result := GridControl;
end;

function TCodeBindings.TcbLinkGridToDataSource.DestObjMemberName: string;
begin
  Result := string.Empty;
end;

procedure TCodeBindings.TcbLinkGridToDataSource.DoBeforeDestChanged;
begin
  FSession.NotifyBeforeDestChanged(Self);
end;

procedure TCodeBindings.TcbLinkGridToDataSource.DoAfterDestChanged;
begin
  FSession.NotifyAfterDestChanged(Self);
end;

function TCodeBindings.TcbLinkGridToDataSource.Identifier: string;
begin
  if Assigned(GridControl) then
    Result := GridControl.Name
  else
    Result := TComponent(FLastKnownDestObj).Name;
  Result := Result + QUICKLINK_SUFFIX;
end;

function TCodeBindings.TcbLinkGridToDataSource.LastKnownDestObj: TObject;
begin
  Result := FLastKnownDestObj;
end;

procedure TCodeBindings.TcbLinkGridToDataSource.GenerateExpressions(Sender: TComponent);
begin
  inherited;
  { The next thing that will be executed is the OnActivated event
  so this override is a way of responding to the link becoming active
  without taking over the OnActivated event }
  Activated(Self);
end;

procedure TCodeBindings.TcbLinkGridToDataSource.Activated(Sender: TComponent);
begin
  inherited;
  FLastKnownDestObj := GridControl;
  FSession.NotifyActiveStatusChanged(Self);
end;

procedure TCodeBindings.TcbLinkGridToDataSource.CodeBindingSetActive(inValue: boolean);
begin
  { inherited SetActive uses a const parameter and so does not match ICodeBinding interface method signature }
  Active := inValue;
end;

procedure TCodeBindings.TcbLinkGridToDataSource.Reactivate;
begin
  { implemented only to get rid of compiler warning that
  TLinkGridToDataSource does not implement abstract method
  TBindComponentDelegate.Reactivate }
  Assert(False);
end;

function TCodeBindings.TcbLinkGridToDataSource.RequiresControlHandler: Boolean;
begin
  { implemented only to get rid of compiler warning that
  TLinkGridToDataSource does not implement abstract method
  TBindComponentDelegate.Reactivate }
  Assert(False);
  Result := False;
end;

function TCodeBindings.TcbLinkGridToDataSource.GetOnAfterSaveValue: TCodeBindingAfterSaveValueEvent;
begin
  Result := FAfterSaveValueEvent;
end;

procedure TCodeBindings.TcbLinkGridToDataSource.SetOnAfterSaveValue(const inEventProc: TCodeBindingAfterSaveValueEvent);
begin
  FAfterSaveValueEvent := inEventProc;
end;

{ TCodeBindings.TcbLinkListControlToField }

constructor TCodeBindings.TcbLinkListControlToField.Create(inOwner: TComponent; inSession: TCodeBindings.TSession);
begin
  inherited Create(inOwner);
  BindingsList := inSession.BindingsList;
  FSession := inSession;
end;

destructor TCodeBindings.TcbLinkListControlToField.Destroy;
begin
  FSession.NotifyBeforeBindingDestroyed(Self);
  inherited;
end;

procedure TCodeBindings.TcbLinkListControlToField.Activated(Sender: TComponent);
begin
  inherited;
  FLastKnownDestObj := Control;
  FSession.NotifyActiveStatusChanged(Self);
end;

function TCodeBindings.TcbLinkListControlToField.DestObj: TObject;
begin
  Result := Control;
end;

function TCodeBindings.TcbLinkListControlToField.DestObjMemberName: string;
begin
  Result := ControlMemberName;
end;

procedure TCodeBindings.TcbLinkListControlToField.DoBeforeDestChanged;
begin
  FSession.NotifyBeforeDestChanged(Self);
end;

procedure TCodeBindings.TcbLinkListControlToField.DoAfterDestChanged;
begin
  FSession.NotifyAfterDestChanged(Self);
end;

function TCodeBindings.TcbLinkListControlToField.Identifier: string;
begin
  if Assigned(Control) then
    Result := Control.Name
  else
    Result := TComponent(FLastKnownDestObj).Name;
  Result := Result + QUICKLINK_SUFFIX;
end;

function TCodeBindings.TcbLinkListControlToField.LastKnownDestObj: TObject;
begin
  Result := FLastKnownDestObj;
end;

function TCodeBindings.TcbLinkListControlToField.GetOnAfterSaveValue: TCodeBindingAfterSaveValueEvent;
begin
  Result := FAfterSaveValueEvent;
end;

procedure TCodeBindings.TcbLinkListControlToField.SetOnAfterSaveValue(const inEventProc: TCodeBindingAfterSaveValueEvent);
begin
  FAfterSaveValueEvent := inEventProc;
end;

{ TCodeBindings.TcbLinkFillControlToField }

constructor TCodeBindings.TcbLinkFillControlToField.Create(inOwner: TComponent; inSession: TCodeBindings.TSession);
begin
  inherited Create(inOwner);
  BindingsList := inSession.BindingsList;
  FSession := inSession;
end;

destructor TCodeBindings.TcbLinkFillControlToField.Destroy;
begin
  FSession.NotifyBeforeBindingDestroyed(Self);
  inherited;
end;

procedure TCodeBindings.TcbLinkFillControlToField.Activated(Sender: TComponent);
begin
  inherited;
  FLastKnownDestObj := Control;
  FSession.NotifyActiveStatusChanged(Self);
end;

function TCodeBindings.TcbLinkFillControlToField.DestObj: TObject;
begin
  Result := Control;
end;

function TCodeBindings.TcbLinkFillControlToField.DestObjMemberName: string;
begin
  Result := ControlMemberName;
end;

procedure TCodeBindings.TcbLinkFillControlToField.DoBeforeDestChanged;
begin
  FSession.NotifyBeforeDestChanged(Self);
end;

procedure TCodeBindings.TcbLinkFillControlToField.DoAfterDestChanged;
begin
  FSession.NotifyAfterDestChanged(Self);
end;

function TCodeBindings.TcbLinkFillControlToField.Identifier: string;
begin
  if Assigned(Control) then
    Result := Control.Name
  else
    Result := TComponent(FLastKnownDestObj).Name;
  Result := Result + QUICKLINK_SUFFIX;
end;

function TCodeBindings.TcbLinkFillControlToField.LastKnownDestObj: TObject;
begin
  Result := FLastKnownDestObj;
end;

function TCodeBindings.TcbLinkFillControlToField.GetOnAfterSaveValue: TCodeBindingAfterSaveValueEvent;
begin
  Result := FAfterSaveValueEvent;
end;

procedure TCodeBindings.TcbLinkFillControlToField.SetOnAfterSaveValue(const inEventProc: TCodeBindingAfterSaveValueEvent);
begin
  FAfterSaveValueEvent := inEventProc;
end;

{ TCodeBindings.TcbBindLink }

constructor TCodeBindings.TcbBindLink.Create(inOwner: TComponent; inSession: TCodeBindings.TSession);
begin
  inherited Create(inOwner);
  BindingsList := inSession.BindingsList;
  FSession := inSession;
end;

destructor TCodeBindings.TcbBindLink.Destroy;
begin
  FSession.NotifyBeforeBindingDestroyed(Self);
  inherited;
end;

procedure TCodeBindings.TcbBindLink.DoOnActivated;
begin
  inherited;
  FLastKnownDestObj := ControlComponent;
  FSession.NotifyActiveStatusChanged(Self);
end;

function TCodeBindings.TcbBindLink.DestObj: TObject;
begin
  Result := ControlComponent;
end;

function TCodeBindings.TcbBindLink.DestObjMemberName: string;
begin
  { TODO 2 : Perhaps look at the format expressions to determine what is happening and get a member name }
  Result := string.Empty;
end;

procedure TCodeBindings.TcbBindLink.DoBeforeDestChanged;
begin
  FSession.NotifyBeforeDestChanged(Self);
end;

procedure TCodeBindings.TcbBindLink.DoAfterDestChanged;
begin
  FSession.NotifyAfterDestChanged(Self);
end;

function TCodeBindings.TcbBindLink.Identifier: string;
begin
  if Assigned(ControlComponent) then
    Result := ControlComponent.Name
  else
    Result := TComponent(FLastKnownDestObj).Name;
  Result := Result + QUICKLINK_SUFFIX;
end;

function TCodeBindings.TcbBindLink.LastKnownDestObj: TObject;
begin
  Result := FLastKnownDestObj;
end;

function TCodeBindings.TcbBindLink.GetOnAfterSaveValue: TCodeBindingAfterSaveValueEvent;
begin
  Result := FAfterSaveValueEvent;
end;

procedure TCodeBindings.TcbBindLink.SetOnAfterSaveValue(const inEventProc: TCodeBindingAfterSaveValueEvent);
begin
  FAfterSaveValueEvent := inEventProc;
end;

{ TCodeBindings.TcbLinkPropertyToField }

constructor TCodeBindings.TcbLinkPropertyToField.Create(inOwner: TComponent; inSession: TCodeBindings.TSession);
begin
  inherited Create(inOwner);
  BindingsList := inSession.BindingsList;
  FSession := inSession;
end;

destructor TCodeBindings.TcbLinkPropertyToField.Destroy;
begin
  FSession.NotifyBeforeBindingDestroyed(Self);
  inherited;
end;

procedure TCodeBindings.TcbLinkPropertyToField.Activated(Sender: TComponent);
begin
  inherited;
  FLastKnownDestObj := Component;
  FSession.NotifyActiveStatusChanged(Self);
end;

function TCodeBindings.TcbLinkPropertyToField.DestObj: TObject;
begin
  Result := Component;
end;

function TCodeBindings.TcbLinkPropertyToField.DestObjMemberName: string;
begin
  Result := ComponentProperty;
end;

procedure TCodeBindings.TcbLinkPropertyToField.DoBeforeDestChanged;
begin
  FSession.NotifyBeforeDestChanged(Self);
end;

procedure TCodeBindings.TcbLinkPropertyToField.DoAfterDestChanged;
begin
  FSession.NotifyAfterDestChanged(Self);
end;

function TCodeBindings.TcbLinkPropertyToField.Identifier: string;
begin
  if Assigned(Component) then
    Result := Component.Name
  else
    Result := TComponent(FLastKnownDestObj).Name;
  Result := Result + QUICKLINK_SUFFIX;
end;

function TCodeBindings.TcbLinkPropertyToField.LastKnownDestObj: TObject;
begin
  Result := FLastKnownDestObj;
end;

function TCodeBindings.TcbLinkPropertyToField.GetOnAfterSaveValue: TCodeBindingAfterSaveValueEvent;
begin
  Result := FAfterSaveValueEvent;
end;

procedure TCodeBindings.TcbLinkPropertyToField.SetOnAfterSaveValue(const inEventProc: TCodeBindingAfterSaveValueEvent);
begin
  FAfterSaveValueEvent := inEventProc;
end;

{ TCodeBindings.TcbLinkControlToField }

constructor TCodeBindings.TcbLinkControlToField.Create(inOwner: TComponent; inSession: TCodeBindings.TSession);
begin
  inherited Create(inOwner);
  BindingsList := inSession.BindingsList;
  FSession := inSession;
end;

destructor TCodeBindings.TcbLinkControlToField.Destroy;
begin
  FSession.NotifyBeforeBindingDestroyed(Self);
  inherited;
end;

procedure TCodeBindings.TcbLinkControlToField.Activated(Sender: TComponent);
begin
  inherited;
  FLastKnownDestObj := GetControlComponent;
  FSession.NotifyActiveStatusChanged(Self);
end;

function TCodeBindings.TcbLinkControlToField.DestObj: TObject;
begin
  Result := GetControlComponent;
end;

function TCodeBindings.TcbLinkControlToField.DestObjMemberName: string;
begin
  Result := GetControlComponentMemberName;
end;

procedure TCodeBindings.TcbLinkControlToField.DoBeforeDestChanged;
begin
  FSession.NotifyBeforeDestChanged(Self);
end;

procedure TCodeBindings.TcbLinkControlToField.DoAfterDestChanged;
begin
  FSession.NotifyAfterDestChanged(Self);
end;

function TCodeBindings.TcbLinkControlToField.Identifier: string;
begin
  if Assigned(Control) then
    Result := Control.Name
  else
    Result := TComponent(FLastKnownDestObj).Name;
  Result := Result + QUICKLINK_SUFFIX;
end;

function TCodeBindings.TcbLinkControlToField.LastKnownDestObj: TObject;
begin
  Result := FLastKnownDestObj;
end;

function TCodeBindings.TcbLinkControlToField.GetOnAfterSaveValue: TCodeBindingAfterSaveValueEvent;
begin
  Result := FAfterSaveValueEvent;
end;

procedure TCodeBindings.TcbLinkControlToField.SetOnAfterSaveValue(const inEventProc: TCodeBindingAfterSaveValueEvent);
begin
  FAfterSaveValueEvent := inEventProc;
end;

end.

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

unit uFluentCodeBindings;

interface

uses
  System.SysUtils
  , System.Classes
  , FMX.Grid
  , uCodeBindings
  { you may need to use my FluentLiveBindings fork
  rather than Malcolm's original. It can be found at
  https://github.com/LachG/FluentLiveBindings }
  , LiveBindings.Fluent
  ;

type
  TCodeBindingsHelper = class helper for TCodeBindings
  public
    class function BindComponent(const Target : TComponent) : IComponentTarget;
    class function BindList(const Target : TComponent) : IListComponentTarget;
    class function BindGrid(const Target : TCustomGrid) : IGridTarget;
  end;



implementation

{ TCodeBindingsHelper }

class function TCodeBindingsHelper.BindComponent(const Target: TComponent): IComponentTarget;
begin
  Result := CGlobal.BindingsList.BindComponent(Target, Target);  { "Too many actual parameters" compile error - see notes above }
end;

class function TCodeBindingsHelper.BindGrid(const Target: TCustomGrid): IGridTarget;
begin
  Result := CGlobal.BindingsList.BindGrid(Target, Target);  { "Too many actual parameters" compile error - see notes above }
end;

class function TCodeBindingsHelper.BindList(const Target: TComponent): IListComponentTarget;
begin
  Result := CGlobal.BindingsList.BindList(Target, Target);  { "Too many actual parameters" compile error - see notes above }
end;

end.

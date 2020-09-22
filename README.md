# CodeBindings

This is a wrapper around the LiveBindings framework that makes it easy to create LiveBindings at runtime. It is primarily focused on binding FMX controls to database fields.

## Usage

You do not need to use the IDE's visual designer or place any LiveBindings components on your form. For the core functionality all you have to do is add one unit to the uses clause of your form

```delphi
implementation

uses uCodeBindings;
```

and then you can define bindings by calling the Add method and providing the FMX control and the TField to it.

```delphi
procedure TForm1.FormCreate(Sender : TObject);
begin
  TCodeBindings.Add(Edit1, Query1Firstname);
  TCodeBindings.Add(Edit2, Query1Surname);
end;
```

There are overloads for all the common out of the box FMX controls, with advanced features such as
* combo boxes that uses the lookup dataset properties of TField to fill the combobox items,
* individual grid column configuration using an anonymous method,
* listview configuration passing an open array of parameters.

## Integration with Malcolm Groves's Fluent.LiveBindings

CodeBindings allows you to use Malcolm Groves's Fluent.LiveBindings wrapper via CodeBindings. This allows you to create Fluent LiveBindings but without requiring you to place a TBindingList component on your form.

To use this integration add a second unit to your uses clause.

```delphi
implementation

uses uCodeBindings, uFluentCodeBindings;
```

and then create Fluent LiveBindings like this
```delphi
procedure TForm1.FormCreate(Sender : TObject);
begin
  TCodeBindings.BindComponent(CheckBox1).Track.ToComponent(CheckBox2, 'IsChecked').BiDirectional;
end;
```

BindComponent, BindGrid and BindList are currently supported, BindExpression is not. While you do not need to place a TBindingList on your form if you are using Fluent Bindings to bind to a control you currently do need to place a TBindSourceDB at design time. I'll try and remove this requirement in the future so Fluent Bindings can be created without any design time components, just like the standard CodeBindings can.



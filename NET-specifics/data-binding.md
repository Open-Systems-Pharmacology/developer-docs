# Data Binding

## Introduction

In this part of the documentation we will talk about the OSPSuite UI and the binding of data to graphic elements. We will present the elements that we are using to achieve this binding - either external like Devexpress or internal to OSPSuite, like the OSPSuite.DataBinding repository.

# Data Binding Overview

The graphical user interface of OSPSuite uses [Winforms](https://en.wikipedia.org/wiki/Windows_Forms) as its UI framework and the [Devexpress Winforms Component](https://docs.devexpress.com/WindowsForms/7874/winforms-controls) to provide additional controls and functionalities. In order to display the data on the controls, a data binding framework has been developed. The data binding is part of two separate repositories, [OSPSuite.DataBinding](https://github.com/Open-Systems-Pharmacology/OSPSuite.DataBinding) and the DevExpress specific [OSPSuite.DataBinding.DevExpress](https://github.com/Open-Systems-Pharmacology/OSPSuite.DataBinding.DevExpress). In almost all cases, simple bindings can be created to implement two way updating of view and objects.

# Data Binding Example

## DTO (Data Transfer Object)

Although we could bind to the properties of an object directly, we generally prefer to use DTOs [Data Transfer Object](https://en.wikipedia.org/wiki/Data_transfer_object) as an intermediate step, in order to be able to structure our data in a manner that makes more sense in displaying. Let's take as an example the binding to a simple TextEdit. We are going to base our example initially to binding a simple float value to the text edit:

So let's say we have defined in our view a TextEdit.

```
private DevExpress.XtraEditors.TextEdit myValueTextEdit;
```

In this example we want to bind the TextEdit to a `float` value. We will create a very simple DTO to hold that value - later on we will also add a validation check for this value. But let's start with the simplest possible form:

```
public class MyValueDTO
{
      public float MyValue { get; set; }
}
```

## Screenbinder

The next step after creating this is to define a screenbinder that would take care of the binding for us. It inherits from the class OSPSuite.DataBinding.ScreenBinder<TObjectType> defined in [OSPSuite.DataBinding](https://github.com/Open-Systems-Pharmacology/OSPSuite.DataBinding/blob/master/src/OSPSuite.DataBinding/ScreenBinder.cs). 

So moving back to the view, we define a screenbinder for this newly created DTO:

```
private readonly ScreenBinder<MyValueDTO> _screenBinder;
```

Since our view is extending `BaseView` (or even as part of the `IView` interface), we have a base virtual function `void InitializeBinding()`. This function should take care of the initializing of the binding, so in our case:

```
public override void InitializeBinding()
{
      base.InitializeBinding();
      _screenBinder.Bind(x => x.MyValue).To(myValueTextEdit); 
}
```

In order to bind to the actual DTO object, we need a `void BindTo(MyValueDTO myValueDTO)` function as part of the interface of the view. This function can then be called from the presenter to provide the DTO object for the actual binding.

So in the view we will have the implementation of this function:

```
public void BindTo(MyValueDTO myValueDTO)
{
      _screenBinder.BindToSource(myValueDTO);
}
```

Like this, the binding is complete. Similarly we could expand the DTO with more fields and use it to bind to various UI elements. In the case we had f.e. a form that would consist of a drop-down, a color selector, and two TextEdits for value input, we would usually create a single DTO that would encapsulate all those values and bind to the separate visual elements. An example of such a more complex binding can be found in [ParameterIdentificationConfigurationView.cs](https://github.com/Open-Systems-Pharmacology/OSPSuite.Core/blob/develop/src/OSPSuite.UI/Views/ParameterIdentifications/ParameterIdentificationConfigurationView.cs), both in the initialization and the binding segments.

When using the screenbinder it is important to remember to dispose it at the end. Usually this is done in the `Dispose()` function of the view - usually located in the designer part of the view (...MyView.Designer.cs):

```
protected override void Dispose(bool disposing)
{
      .
      .
      .

      _screenBinder.Dispose();
      base.Dispose(disposing);
}
```

When having more than one binders, it would be more reasonable to create a method called something like `disposeBinders()` and then just call from the `Dispose(bool disposing)` function above.

## Validation

Going back to the simple example that we are presenting here. If we want to add validation to the values that come as input by the user for the TextEdit, we need to implement in the DTO the `IValidatable` interface. Then we have to define the rule that we need validated. Let's say that we need the float value that we are reading to be greater than 2.


```
public class MyValueDTO : IValidatable
{
      public float MyValue { get; set; }

      public MyValueDTO()
      {
         Rules.Add(AllRules.myValueGreaterThanTwo);
      }

      private static class AllRules
      {
            private static IBusinessRule myValueGreaterThanTwo
            {
                  get
                  {
                        return CreateRule.For<MyValueDTO>()
                              .Property(item => item.MyValue)
                              .WithRule((x, value) => value > 2.0)
                              .WithError("Value must be greater than 2");
                  }
            }
      }
}
```

As you can see in the above example, we can also define an error text to be displayed to the user in case that the validation for the input value fails.
Important Note: of course in the case of actual OSPSuite code, it has to be stressed that the error string should not be hard coded, but would rather be define in `UIConstants.Error`.

To finalize the validation, we should also expand the binding initialization to also register the validation:

```
public override void InitializeBinding()
{
      base.InitializeBinding();
      _screenBinder.Bind(x => x.MyValue).To(myValueTextEdit); 
      RegisterValidationFor(_screenBinder, NotifyViewChanged);
}
```

## Formatting

Additionally, we can use a formatter to specifically format the data displayed in the view. We can use an existing formatter, like the [DateTimeFormatter](https://github.com/Open-Systems-Pharmacology/OSPSuite.Core/blob/develop/src/OSPSuite.Core/Services/DateTimeFormatter.cs) in order to fix the displaying format when we are binding to a frequently used type like in this case `DateTime`. Alternatively there is of course the possibility to create a custom formatter. Let's say for example we have a class `MyClass` that has a member function `string GetName()` that returns the name of the object. If we want to bind objects of this type to a 'ComboBoxEdit' we cannot do it directly - we will have to use a custom formatter to access the string name of the object. Additionally let's assume we want to display a specific string  in case the bound value is `null`. To achieve all this we would write the following formatter:

```
public class MyClassFormatter : IFormatter<MyClass>
{
      public string Format(MyClass valueToFormat)
      {
            if (valueToFormat == null)
                  return "No value selected";

            return valueToFormat.GetName();
      }
}
```

Again please note that the hard coded string only exists in the above example for simplicity -  in the real OSPSuite code it would be part of `Captions`.

Then when performing the actual binding:

```
private OSPSuite.UI.Controls.UxComboBoxEdit myComboBoxEdit;

.
.
.

//Here we are assuming we have created a DTO, the .MyClass returns an object of type MyClass 
private readonly ScreenBinder<MyDTO> _screenBinder = new ScreenBinder<MyDTO>;

private readonly IFormatter<MyClass> _myClassFormatter = new MyClassFormatter();

_screenBinder.Bind(x => x.MyClass)
      .To(myComboBoxEdit)
      .WithFormat(_myClassFormatter);
```

## Further possibilities

There are further functionalities that can be achieved using the binding framework. For example using the `_screenBinder.WithValues(...)` a set of values can be specified as possible values for the UI element ( drop-down menu f.e. ). 

Actions like `_screenBinder.Changed()`, `_screenBinder.OnValueUpdating` and more can be used for the View to be subscribed to them and handle them accordingly when they happen. `RegisterValidationFor(....)` is already using events like that to handle the validation.


## DTO Mappers

Concerning the creation and transfer of data to and from the DTO, when we have a complicated scenario we usually create a separate mapper class. We do this to avoid having all the code in the presenter. F.e. you can refer to the mapping of the `JournalPage` to `JournalPageDTO` in [JournalPageToJournalPageDTOMapper](https://github.com/Open-Systems-Pharmacology/OSPSuite.Core/blob/develop/src/OSPSuite.Presentation/Mappers/JournalPageToJournalPageDTOMapper.cs). 


# Binding to a Grid

When using a Grid as a visual element, a special type of binder can be used to bind data to the contents of the grid : 

```
OSPSuite.DataBinding.DevExpress.XtraGrid.GridViewBinder<T>
```

The logic of using this binder is pretty similar to what we have described above. Since in the grid we have multiple lines we would usually use repositories to bind to, like `RepositoryItemComboBox` , `RepositoryItemCheckedComboBoxEdit`, or even button repositories of `UxRepositoryItemButtonEdit` type if we want to fill a column with clickable buttons. For example assuming we have defined a DTO class `myDTO` with members `Name` , `Type` etc: 


```
private readonly GridViewBinder<myDTO> _gridViewBinder;

public override void InitializeBinding()
{
      _gridViewBinder.AutoBind(x => x.Name)
            .WithCaption("Name");

      _gridViewBinder.AutoBind(x => x.Type)
            .WithCaption("Type");

      _gridViewBinder.Changed += NotifyViewChanged;
}
```

The `.WithCaption(...)` (that same as above in real world code would be called with captions and not hard coded strings in the call), defines the title of the column. Please note that we are using `.AutoBind(...)` instead of simple `.Bind(...)` to do the binding. In the case of `.Bind(...)` we are doing the binding, whereas in the case of `.AutoBind(...)` it is the .NET framework that is doing it. If we were to use the `.Bind(...)` we would not get the 'x' error symbol that comes from the validation refreshed when the data changes. Note also that we are subscribing to the event of the grid data changing.

## Unbound Column in a Grid

Sometimes we want to add to our Grid a column that is not bound to the DTO. In the simplest case that could be a column with a constant value. A more interesting example for that would be a column that contains clickable buttons. We can do this f.e. like this:

```
public override void InitializeBinding()
{
      private readonly UxRepositoryItemButtonEdit _buttonRepository;

      //devexpress predefined buttons can f.e. be used in the button repository. Here we are using th predifined "Clear" button
      _buttonRepository = new UxRepositoryItemButtonEdit(ButtonPredefines.Clear);
      .
      .
      .

      _gridViewBinder.AddUnboundColumn()
            .WithCaption("")
            .WithRepository(x => _buttonRepository)
            .WithShowButton(ShowButtonModeEnum.ShowAlways)
            .WithFixedWidth(UIConstants.Size.EMBEDDED_BUTTON_WIDTH);
      
      .
      .
      .

      //call the presenter to handle the clicking of the button
      _buttonRepository.ButtonClick += (o, e) => OnEvent(() => _presenter.HandleButtonClick(_gridViewBinder.FocusedElement));
}
```

Please also note the subscription to the `ButtonClick` of the button repository, to handle the clicking of one of the buttons of the grid.
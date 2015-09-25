# sitecore-font-icon-picker-field
A custom Sitecore field for selecting font icon CSS classes

http://www.layerworks.com/blog/2015/8/26/icon-font-picker-custom-field

## Example Configuration
Place this JSON into the field's Source

```javascript
[
  { 
    title: "Company Fonts",
    src: "/Content/css/company-fonts.css",
    regex: "^\\.company-.*",
    columns: 5 
  },
  { 
    title: "Font Awesome",
    src: "/Content/css/font-awesome.css",
    regex: "^\\.fa-.*", 
    baseClass: "fa", 
    columns: 4
  }
]
```
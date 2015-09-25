<%@ Page Language="C#" AutoEventWireup="true" EnableViewState="false" CodeBehind="Browse.aspx.cs" Inherits="LayerWorks.Web.sitecore.shell.Applications.Dialogs.FontIconPickerField.Browse" %>

<%@ Import Namespace="Sitecore.Globalization" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">

    <title>Font Icon Picker Field</title>

    <style>
        /* Basic styles */
        body, html {
            margin: 0;
            font-family: sans-serif;
            font-size: 14px;
        }

        /* Control bar */
        .ctrls {
            background: #F5F5F5;
            border-bottom: 1px solid #CCC;
            position: fixed;
            top: 0;
            width: 100%;
            z-index: 999;
        }

            .ctrls .inner {
                padding: 1.5em 2em;
            }

            .ctrls input, .ctrls button {
                font-size: 16px;
                padding: .5em 1em;
            }

            .ctrls input {
                width: 200px !important;
                margin: 0 !important;
                border: 1px solid #CCC;
            }

                .ctrls input:focus {
                    outline: 0;
                }

                .ctrls input.no-results {
                    box-shadow: 0 0 10px 2px #ff0000;
                    box-shadow: 0 0 10px 2px rgba(255, 0, 0, 0.3);
                    border: 1px solid red;
                }

            .ctrls button {
                margin-left: 2em;
            }

            .ctrls .name, .ctrls .preview, .ctrls button {
                float: right;
            }

            .ctrls .preview {
                margin-left: 10px;
            }

            .ctrls .sm, .ctrls .name {
                font-size: 14px;
                margin-top: 10px;
            }

            .ctrls .med {
                font-size: 30px;
                margin-top: 2px;
            }

            .ctrls .lg {
                font-size: 50px;
                margin-top: -10px;
            }

        /* Results listing */
        .results {
            margin-top: 5em;
            padding: 2em 2em 1em 2em;
        }

            .results table {
                margin-bottom: 1em;
            }

            .results .highlight {
                background-color: yellow;
            }

            .results td {
                padding: .2em;
            }

            .results .name, .results i {
                vertical-align: middle;
                display: inline-block;
                cursor: pointer;
            }

            .results .icon {
                font-family: inherit;
                font-size: 14px;
            }

        .name {
            color: #AAA;
            padding-left: 10px;
        }

        .results .name:hover {
            color: black;
        }

        .results .selected *, .ctrls .preview * {
            color: black;
        }

        /* Fix for flat icon */
        i[class^="flaticon-"]:before,
        i[class=" flaticon-"]:before,
        i[class^="flaticon-"]:after,
        i[class=" flaticon-"]:after {
            margin-left: inherit;
            font-size: inherit;
        }
    </style>
</head>
<body>

    <form id="fontIconPicker" runat="server">
        <div class="ctrls">
            <div class="inner">
                <button onclick="closeAndReturn();"><%= Translate.Text("Select") %></button>
                <span class="preview lg"><i></i></span>
                <span class="preview med"><i></i></span>
                <span class="preview sm"><i></i></span>
                <span class="name"></span>
                <input type="text" placeholder="<%= Translate.Text("Type here to search") %>" />
            </div>
        </div>
        <div class="results">
            <asp:Repeater ID="rptFontIconSet" OnItemDataBound="rptFontIconSet_OnItemDataBound" runat="server">
                <ItemTemplate>
                    <asp:Literal ID="litTitle" runat="server"></asp:Literal>
                    <asp:DataList ID="dlFontIconSet" Width="100%" RepeatDirection="Vertical" runat="server">
                        <ItemTemplate>
                            <div class="icon" onclick="setIcon('<%# Container.DataItem.ToString() %>');">
                                <i class="<%# Container.DataItem.ToString() %>"></i><span class="name"><%# Container.DataItem.ToString() %></span>
                            </div>
                        </ItemTemplate>
                    </asp:DataList>
                    <asp:Literal ID="litFontIconSetMessage" runat="server"></asp:Literal>
                </ItemTemplate>
            </asp:Repeater>
            <asp:Literal ID="litMessage" runat="server"></asp:Literal>
        </div>
    </form>

    <script src="/sitecore/shell/Controls/Lib/jQuery/jquery.js" type="text/javascript"></script>
    <script>

        (function ($) {

            var selectedIcon = '<%= Request.QueryString["value"] %>',
                $icons = $('.icon'),
                $ctrls = $('.ctrls'),
                $ctrlsInput = $('input', $ctrls),
                $selectButton = $('button', $ctrls),
                $preview = $('.preview', $ctrls),
                $name = $('.name', $ctrls),
                timeout;

            window.setIcon = function (className) {

                $icons.removeClass('selected');
                selectedIcon = className;
                $name.text(className);

                if (className) {
                    $('.' + className).closest('.icon').addClass('selected');
                    $selectButton.attr('disabled', '');
                    $preview.find('i').attr('class', className);
                    $preview.show();
                } else {
                    $preview.hide();
                    $selectButton.attr('disabled', 'disabled');
                }
            }

            setIcon(selectedIcon);

            window.closeAndReturn = function () {
                window.top.returnValue = selectedIcon;
                window.top.dialogClose(selectedIcon);
            }

            $ctrlsInput.keyup(function () {

                var val = $(this).val(),
                    scrollPos = 0;;

                $icons.unhighlight();

                if (timeout) {
                    clearTimeout(timeout);
                }

                if (val && val.length > 1) {

                    var words = val.split(' ');

                    for (var i = 0; i < words.length; i++) {
                        $icons.highlight(words[i]);
                    }

                    var $firstMatch = $('.highlight').first();
                    if ($firstMatch.length === 1) {
                        $ctrlsInput.removeClass('no-results');
                        scrollPos = $firstMatch.offset().top - 100;
                    } else {
                        $ctrlsInput.addClass('no-results');
                    }
                }

                timeout = setTimeout(function () {
                    smoothScroll(scrollPos);
                }, 500);
            });

            window.smoothScroll = function (scrollPos) {
                $('html,body').stop().animate({
                    scrollTop: scrollPos
                }, 1000);
            }

            $.extend({
                highlight: function (node, re, nodeName, className) {
                    if (node.nodeType === 3) {
                        var match = node.data.match(re);
                        if (match) {
                            var highlight = document.createElement(nodeName || 'span');
                            highlight.className = className || 'highlight';
                            var wordNode = node.splitText(match.index);
                            wordNode.splitText(match[0].length);
                            var wordClone = wordNode.cloneNode(true);
                            highlight.appendChild(wordClone);
                            wordNode.parentNode.replaceChild(highlight, wordNode);
                            return 1; // skip added node in parent
                        }
                    } else if ((node.nodeType === 1 && node.childNodes) && // only element nodes that have children
                        !/(script|style)/i.test(node.tagName) && // ignore script and style nodes
                        !(node.tagName === nodeName.toUpperCase() && node.className === className)) { // skip if already highlighted
                        for (var i = 0; i < node.childNodes.length; i++) {
                            i += $.highlight(node.childNodes[i], re, nodeName, className);
                        }
                    }
                    return 0;
                }
            });

            $.fn.unhighlight = function (options) {
                var settings = {
                    className: 'highlight',
                    element: 'span'
                };
                $.extend(settings, options);

                return this.find(settings.element + "." + settings.className).each(function () {
                    var parent = this.parentNode;
                    parent.replaceChild(this.firstChild, this);
                    parent.normalize();
                }).end();
            };

            $.fn.highlight = function (words, options) {
                var settings = {
                    className: 'highlight',
                    element: 'span',
                    caseSensitive: false,
                    wordsOnly: false
                };
                $.extend(settings, options);

                if (words.constructor === String) {
                    words = [words];
                }
                words = $.grep(words, function (word, i) {
                    return word !== '';
                });
                words = $.map(words, function (word, i) {
                    return word.replace(/[-[\]{}()*+?.,\\^$|#\s]/g, "\\$&");
                });
                if (words.length === 0) {
                    return this;
                };

                var flag = settings.caseSensitive ? "" : "i";
                var pattern = "(" + words.join("|") + ")";
                if (settings.wordsOnly) {
                    pattern = "\\b" + pattern + "\\b";
                }
                var re = new RegExp(pattern, flag);

                return this.each(function () {
                    $.highlight(this, re, settings.element, settings.className);
                });
            };

        })(jQuery);

    </script>

</body>
</html>

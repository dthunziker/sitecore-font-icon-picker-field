using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;
using System.Web.Script.Serialization;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using Page = System.Web.UI.Page;

namespace LayerWorks.Web.sitecore.shell.Applications.Dialogs.FontIconPickerField
{
    public partial class Browse : Page
    {
        private List<Dictionary<string, dynamic>> _jsonData;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                ParseConfiguration();
                BindIconSets();
            }
        }

        private void ParseConfiguration()
        {
            try
            {
                string json = Request.QueryString["source"];
                var jss = new JavaScriptSerializer();
                _jsonData = jss.Deserialize<List<Dictionary<string, dynamic>>>(json);
            }
            catch (Exception)
            {
                litMessage.Text = @"<p>The field's 'Source' parameter is either missing or is not valid JSON.</p>
                                    <p>Example configurations can be found at <a href=""https://github.com/dthunziker/sitecore-font-icon-picker-field"" target=""_blank"">github.com/dthunziker/sitecore-font-icon-picker-field</a></p>";
            }
        }

        private void BindIconSets()
        {
            if (_jsonData != null)
            {
                rptFontIconSet.DataSource = _jsonData;
                rptFontIconSet.DataBind();
            }
        }

        private void AddStyleSheet(Uri src)
        {
            HtmlLink style = new HtmlLink { Href = src.ToString() };
            style.Attributes.Add("rel", "stylesheet");
            style.Attributes.Add("type", "text/css");

            Page.Header.Controls.Add(style);
        }

        private static string CleanUp(string originalString)
        {
            string outputString;

            // Strip all line-breaks
            using (StringReader reader = new StringReader(originalString))
            using (StringWriter writer = new StringWriter())
            {
                string line;
                while ((line = reader.ReadLine()) != null)
                {
                    if (line.Trim().Length > 0)
                        writer.Write(line);
                }
                outputString = writer.ToString();
            }

            // Remove spaces
            return Regex.Replace(outputString, @"\s+", string.Empty);
        }

        private IEnumerable<string> ParseCssClassNames(Uri src, string pattern, string baseClass)
        {
            List<string> icons = new List<string>();

            try
            {
                string path = Server.MapPath(src.ToString());
                string text = CleanUp(File.ReadAllText(path));
                string[] rules = text.Split('}');

                foreach (string rule in rules)
                {
                    string[] ruleParts = rule.Split('{');
                    if (ruleParts.Length != 2)
                    {
                        continue;
                    }

                    // Remove CSS comments
                    string className = Regex.Replace(ruleParts[0], @"\/\*.*\*\/", string.Empty);

                    className = className
                        .Split(',')[0] // Take the first selector
                        .Split('[')[0] // Exclude attribute selector portion
                        .Split(':')[0]; // Exclude pseudo class portion

                    // Ensure that we're dealing with a unique/valid icon class
                    if (string.IsNullOrEmpty(className) ||
                       icons.Contains(className) ||
                        !ruleParts[1].Contains("content"))
                    {
                        continue;
                    }

                    if (string.IsNullOrEmpty(pattern) || Regex.IsMatch(className, pattern))
                    {
                        className = className.Replace(".", string.Empty);
                        if (!string.IsNullOrEmpty(baseClass))
                        {
                            className = string.Format("{0} {1}", baseClass, className);
                        }
                        icons.Add(className);
                    }
                }
            }
            catch (Exception) { }

            return icons.OrderBy(x => x);
        }

        protected void rptFontIconSet_OnItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            DataList dlFontIconSet = (DataList)e.Item.FindControl("dlFontIconSet");
            Literal litTitle = (Literal)e.Item.FindControl("litTitle");
            Literal litFontIconSetMessage = (Literal)e.Item.FindControl("litFontIconSetMessage");

            Dictionary<string, dynamic> config = (Dictionary<string, dynamic>)e.Item.DataItem;

            dynamic src, regex, baseClass, title, columns;

            config.TryGetValue("src", out src);
            config.TryGetValue("regex", out regex);
            config.TryGetValue("baseClass", out baseClass);
            config.TryGetValue("title", out title);
            config.TryGetValue("columns", out columns);

            if (!string.IsNullOrEmpty(title))
            {
                litTitle.Text = string.Format("<h2>{0}</h2>", title);
            }

            Uri sourceUri;
            if (!Uri.TryCreate(src, UriKind.Relative, out sourceUri))
            {
                litFontIconSetMessage.Text = "'src' parameter is either missing or is not a valid relative path";
                return;
            }

            AddStyleSheet(sourceUri);

            dlFontIconSet.RepeatColumns = columns ?? 5;
            dlFontIconSet.DataSource = ParseCssClassNames(sourceUri, regex, baseClass);
            dlFontIconSet.DataBind();
        }
    }
}
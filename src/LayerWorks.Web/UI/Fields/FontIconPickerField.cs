using Sitecore.Shell.Applications.ContentEditor;
using Sitecore.Text;
using Sitecore.Web.UI.Sheer;
using System;

namespace LayerWorks.Web.UI.Fields
{
    public class FontIconPickerField : Text
    {
        public string Source { get; set; }

        protected override void OnLoad(EventArgs e)
        {
            if (!Sitecore.Context.ClientPage.IsEvent)
            {
                SetViewStateString("source", Source);
            }

            base.OnLoad(e);
        }

        public override void HandleMessage(Message message)
        {
            if (message["id"] != ID || string.IsNullOrEmpty(message.Name))
            {
                return;
            }

            switch (message.Name)
            {
                case "iconPicker:clear": ClearValue(); break;
                case "iconPicker:browse": Browse(); break;
            }

            base.HandleMessage(message);
        }

        private void ClearValue()
        {
            if (Disabled || ReadOnly)
            {
                return;
            }

            if (!string.IsNullOrEmpty(Value))
            {
                SetModified();
            }

            Value = string.Empty;
        }

        private void Browse()
        {
            if (Disabled || ReadOnly)
            {
                return;
            }

            Sitecore.Context.ClientPage.Start(this, "BrowseIconDialog");
        }

        protected void BrowseIconDialog(ClientPipelineArgs args)
        {
            if (args.IsPostBack)
            {
                if (args.HasResult)
                {
                    Value = args.Result;
                    SetModified();
                }
            }
            else
            {
                UrlString urlString = new UrlString("/sitecore/shell/Applications/Dialogs/FontIconPickerField/Browse.aspx");
                urlString.Append("source", GetViewStateString("source"));
                urlString.Append("value", Value);
                SheerResponse.ShowModalDialog(urlString.ToString(), "1120", "600", string.Empty, true);
                args.WaitForPostBack();
            }
        }
    }
}

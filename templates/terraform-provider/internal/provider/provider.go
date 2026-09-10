package provider

import (
	"context"

	"github.com/hashicorp/terraform-plugin-framework/datasource"
	"github.com/hashicorp/terraform-plugin-framework/provider"
	"github.com/hashicorp/terraform-plugin-framework/provider/schema"
	"github.com/hashicorp/terraform-plugin-framework/resource"
)

var _ provider.Provider = &exampleProvider{}

type exampleProvider struct {
	version string
}

func New(version string) func() provider.Provider {
	return func() provider.Provider {
		return &exampleProvider{version: version}
	}
}

func (p *exampleProvider) Metadata(ctx context.Context, req provider.MetadataRequest, resp *provider.MetadataResponse) {
	resp.TypeName = "example"
	resp.Version = p.version
}

func (p *exampleProvider) Schema(ctx context.Context, req provider.SchemaRequest, resp *provider.SchemaResponse) {
	resp.Schema = schema.Schema{
		MarkdownDescription: "The example provider.",
	}
}

func (p *exampleProvider) Configure(ctx context.Context, req provider.ConfigureRequest, resp *provider.ConfigureResponse) {
}

func (p *exampleProvider) Resources(ctx context.Context) []func() resource.Resource {
	return nil
}

func (p *exampleProvider) DataSources(ctx context.Context) []func() datasource.DataSource {
	return nil
}

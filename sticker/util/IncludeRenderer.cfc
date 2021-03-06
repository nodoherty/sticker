/**
 * I exist to render registered assets as an HTML include
 *
 */

component output=false {


	/**
	 * I render a CSS include
	 *
	 * @href.hint                 The URL of the CSS to include
	 * @includeTrailingSlash.hint Whether or not to include a trailing HTML element slash (i.e. for XHTML documents)
	 * @media.hint                Target devices for the CSS
	 */
	public string function renderCssInclude(
		  required string  href
		,          string  media                = ""
		,          boolean includeTrailingSlash = false
	) output=false {
		var rendered = '<link rel="stylesheet" type="text/css" href="#arguments.href#"';

		if ( Len( Trim( arguments.media ) ) ) {
			rendered &= ' media="#arguments.media#"';
		}
		if ( arguments.includeTrailingSlash ) {
			rendered &= " /";
		}

		return rendered & ">";
	}

	/**
	 * I render a JS include
	 *
	 * @src.hint The URL of the javacript to include
	 */
	public string function renderJsInclude( required string src ) output=false {
		return '<script src="#arguments.src#"></script>';
	}

	/**
	 * I render CFML data as javascript data in a script block
	 *
	 * @data.hint Structure of data to be available to javascript
	 */
	public string function renderData( required struct data, string variableName="cfrequest" ) output=false {
		return '<script>#arguments.variableName#=#SerializeJson( arguments.data )#</script>';
	}

	/**
	 * I wrap passed content in IE conditional tags
	 *
	 * @content.hint The content, i.e. a script or link tag, to be wrapped
	 * @condition.hint The condition with which to wrap the content, e.g. "IE lt 7" or "!IE"
	 */
	public string function wrapWithIeConditional( required string content, required string condition ) output=false {
		if ( arguments.condition == "!IE" ) {
			return '<!--[if #arguments.condition#]>-->#arguments.content#<!-- <![endif]-->';
		}
		return "<!--[if #arguments.condition#]>#arguments.content#<![endif]-->";
	}

	/**
	 * I take a collection of assets and render includes for each one
	 *
	 * @assets.hint A collection of sticker assets
	 */
	public struct function addRenderedIncludesToAssets( required struct assets ) output=false {
		for ( var assetId in arguments.assets ) {
			var asset    = arguments.assets[ assetId ];
			var rendered = asset.getType() == "js" ? renderJsInclude( asset.getUrl() ) : renderCssInclude( href=asset.getUrl(), media=asset.getMedia() );

			if ( Len( Trim( asset.getIe() ) ) ) {
				rendered = wrapWithIeConditional( rendered, asset.getIe() );
			}

			arguments.assets[ assetId ].setRenderedInclude( rendered );
		}
		return arguments.assets;
	}
}
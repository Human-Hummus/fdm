const stdlib = """
func style_and_class(){
	if (is_defined($class)){
		` class="`$class`" `
	}
	if (is_defined($style)){
		` style="`$style`" `
	}
}

func b(){
	if (eql($format, html)){
		`<b`style_and_class()`>`$input`</b>`
	}
	if (eql($format, markdown)){
		`**`$input`**`
	}
}
func i(){
	if (eql($format, html)){
		`<em`style_and_class()`>`$input`</em>`
	}
	if (eql($format, markdown)){
		`*`$input`*`
	}
}

func div(){
	if (eql($format, html)){
		`<div`style_and_class()`>`$input`</div>`
	}
	if (eql($format, markdown)){
		$input
	}
}

func h1(){
	if (eql($format, html)){
		`<h1`style_and_class()`>`$input`</h1>`
	}
	if (eql($format, markdown)){
		`\n# `$input`\n`
	}
}
func h2(){
	if (eql($format, html)){
		`<h2`style_and_class()`>`$input`</h2>`
	}
	if (eql($format, markdown)){
		`\n## `$input`\n`
	}
}

func h3(){
	if (eql($format, html)){
		`<h3`style_and_class()`>`$input`</h3>`
	}
	if (eql($format, markdown)){
		`\n### `$input`\n`
	}
}

func newline(){
	if (eql($format, html)){
		`<br>`
	}
	if (eql($format, markdown)){
		`\n`
	}
}

func body(){
	if (eql($format, html)){
		`<!DOCTYPE HTML>`
		`<html>`
			`<head>`
				if (is_defined($title)){`<title>`$title`</title>`}
				if (is_defined($favicon)){`<link rel="icon" type="image/x-icon" href="`$favicon`">`}
			`</head>`
			`<body>`
				$input
			`</body>`
		`</html>`
	}
	if (eql($format, markdown)){
		$input
	}
	
}

func link(link){
	if (eql($format, html)){
		`<a href="`$link`"`style_and_class()`>`$input`</a>`
	}
	if (eql($format, markdown)){
		
	}
}
func center(){
	if (eql($format, html)){
		div(style=`text-align:center;margin 0 auto;`){$input}
	}
}

func plaintext(){
	$plaintext_iter=0;
	while (not(eql($plaintext_iter, len($input)))){
		if (eql($input[$plaintext_iter], `\n`)){
			newline()
		}

		elif (and(eql(format, "markdown"), eql($input[$plaintext_iter], `\\`))){
			`\\\\`
		}
		else{
			$input[$plaintext_iter]
		}
		$plaintext_iter=sum($plaintext_iter, 1);
	}
}


func quote(){
	if (eql($format, html)){
		`<blockquote>`$input`</blockquote>`
	}
	if (eql($format, markdown)){
		`>`
		$par_iter = 0;
		while (not(eql($par_iter, len($input)))){
			if (eql($input[$par_iter], `\n`)){
				`\n>`
			}
			else{
				$input[$par_iter]
			}
			$par_iter=sum($par_iter, 1);
		}
	}
}
func q(){
	if (eql($format, html)){
		`<q>`$input`</q>`
	}
	if (eql($format, markdown)){
		`"`$input`"`
	}
}

func p(){
	$paragraph_iter=0;
	$output=``;
	if (eql(format,html)){
		$output=$output`<p style="text-indent:50px;">`;
	}
	while (not(eql($paragraph_iter, len($input)))){
		if (or(eql($input[$paragraph_iter], `\n`), eql($input[$paragraph_iter], ` `), eql($input[$paragraph_iter], `\t`))){
			if (not(eql(len($output), 0))){
				if (not(eql($output[sum(len($output), `-1`)], ` `))){
					$output=$output ` `;
				}
			}
		}
		else{
			$output = $output $input[$paragraph_iter];
		}
		$paragraph_iter=sum($paragraph_iter, 1);
	}
	if (eql($format, markdown)){
		$output = `\n\n`$output`\n\n`;
	}
	if (eql(format,html)){
		$output=$output`</p>`;
	}
	$output
}

func sup(){
	if (or(eql($format, html), eql($format, markdown))){
		`<sup>`$input`</sup>`
	}
}
func sub(){
	if (or(eql($format, html), eql($format, markdown))){
		`<sup>`$input`</sup>`
	}
}


func frac(a,b){
	if (or(eql($format, html), eql($format, markdown))){
		sup{$a}`/`sub{$b}
		
	}
}


$mult=`×`;
$plusmin=`±`;
$sqrt=`√`;
$noteq=`≠`;
$approxeq="≈";
$theta=`θ`;

"""

const stdlib = """
single_import
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
    if (eql($format, latex)){
      `\\textbf{`$input`}`
    }
}
func i(){
	if (eql($format, html)){
		`<em`style_and_class()`>`$input`</em>`
	}
	if (eql($format, markdown)){
		`*`$input`*`
	}
    if (eql($format, latex)){
      `\\textit{`$input`}`
    }
}

func div(){
	if (eql($format, html)){
		`<div`style_and_class()`>`$input`</div>`
	}
	if (eql($format, markdown)){
		$input
	}
	if (eql($format, latex)){
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
    if (eql($format, latex)){
      `\\section{`$input`}`
    }
}
func h2(){
	if (eql($format, html)){
		`<h2`style_and_class()`>`$input`</h2>`
	}
	if (eql($format, markdown)){
		`\n## `$input`\n`
	}
    if (eql($format, latex)){
      `\\subsection{`$input`}`
    }
}

func h3(){
	if (eql($format, html)){
		`<h3`style_and_class()`>`$input`</h3>`
	}
	if (eql($format, markdown)){
		`\n### `$input`\n`
	}
    if (eql($format, latex)){
      `\\subsubsection{`$input`}`
    }
}

func newline(){
	if (eql($format, html)){
		`<br>`
	}
	if (eql($format, markdown)){
		`\n`
	}
	if (eql($format, latex)){
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
            `<style>ul{margin-left:5%;}</style>`
				$input
			`</body>`
		`</html>`
	}
	if (eql($format, markdown)){
		$input
	}
    if (eql($format, latex)){
      `\\documentclass[english]{article}`
      `\\usepackage{hyperref}`
      `\\usepackage{amsmath}`
      `\\usepackage{unicode-math}`
      `\\usepackage[utf8]{inputenc}`
      if (is_defined($title)){
        `\\title{`$title`}`
      }
      `\\begin{document}`
      if (is_defined($title)){
        `\\maketitle`
      }
      $input
      `\\end{document}`
    }
	
}

func link(link){
	if (eql($format, html)){
		`<a href="`$link`"`style_and_class()`>`$input`</a>`
	}
	if (eql($format, markdown)){
	    `[`$input`](`$link`)`	
	}
    if (eql($format, latex)){
        `\\href{`link`}{`$input`}`
    }
}
func center(){
	if (eql($format, html)){
		div(style=`text-align:center;`){$input}
	}
    else{
      $input
    }
}

func text(){
	$text_iter=0;
	while (not(eql($text_iter, len($input)))){
		if (eql($input[$text_iter], `\n`)){
			newline()
		}

		elif (and(eql($format, markdown), eql($input[$text_iter], `\\`))){
			`\\`
		}
		elif (and(eql($format, html), eql($input[$text_iter], `<`))){
			`&lt;`
		}
		elif (and(eql($format, html), eql($input[$text_iter], `>`))){
			`&gt;`
		}
        elif (and(eql($format, html), eql($input[$text_iter], `&`))){
			`&amp;`
		}
		elif (and(eql($format, markdown), eql($input[$text_iter], `<`))){
			`\\<`
		}
		elif (and(eql($format, markdown), eql($input[$text_iter], `>`))){
			`\\>`
		}
		else{
			$input[$text_iter]
		}
		$text_iter=sum($text_iter, 1);
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
    if (eql($format, latex)){
      `\\begin{quote}`
      $input
      `\\end{quote}`

    }
}
func q(){
	if (eql($format, html)){
		`<q>`$input`</q>`
	}
	if (eql($format, markdown)){
		`"`$input`"`
	}
	if (eql($format, latex)){
		`"`$input`"`
	}

}

func p(){
	$paragraph_iter=0;
	$output=``;
	if (eql($format,html)){
		$output=$output`<p style="text-indent:50px;">`;
	}	
    if (eql($format,latex)){
		$output=$output`\\begin{paragraph}`;
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
	if (eql($format,html)){
		$output=$output`</p>`;
	}
	if (eql($format,latex)){
		$output=$output`\\end{paragraph}`;
	}
	$output
}

func sup(){
	if (or(eql($format, html), eql($format, markdown))){
		`<sup>`$input`</sup>`
	}
    if (eql($format, latex)){
        `^{`$input`}`
    }
}
func sub(){
	if (or(eql($format, html), eql($format, markdown))){
		`<sup>`$input`</sup>`
	}
    if (eql($format, latex)){
        `_{`$input`}`
    }
}


func frac(a,b){
	if (or(eql($format, html), eql($format, markdown))){
		`(`sup{$a}`/`sub{$b}`)`
		
	}
    if (eql($format, latex)){
        `$\\frac{`$a`}{`$b`}$`
    }
}


$mult="×";
$plusmin="±";
$sqrt="√";
$noteq="≠";
$approxeq="≈";
$theta="θ";

if (eql($format, latex)){
  $mult="\\(\\times\\)";
  $plusmn="U+00B1";
  $sqrt="$\\sqrt[]{}$";
  $noteq="$\\ne$";
  $approxeq="$\\approx$";
  $theta="$\\muptheta$";
}

"""

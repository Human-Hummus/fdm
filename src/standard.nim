const stdlib = """
single_import

$within_math_scope=false;

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

func sup()~{
  if (or(eql($format, html), eql($format, markdown))){
    `<sup>`$input`</sup>`
  }
    if (eql($format, latex)){
      if (not($within_math_scope)){
        "$" 
        $within_math_scope=true;
        `^{`$input`}`
        "$"
        $within_math_scope=false;
      }
      else{
        `^{`$input`}`
      }
    }
}
func sub()~{
  if (or(eql($format, html), eql($format, markdown))){
    `<sub>`$input`</sub>`
  }
    if (eql($format, latex)){
      if (not($within_math_scope)){
        "$" 
        $within_math_scope=true;
        `_{`$input`}`
        "$"
        $within_math_scope=false;
      }
      else{
        `_{`$input`}`
      }
    }
}

func code(){
  if (eql($format, html)){
    `<code>`$input`</code>`
  }
  elif (eql($format, markdown)){
    `\``$input`\``
  }
}


func frac(~a,~b){
  if (or(eql($format, html), eql($format, markdown))){
      `(`sup{$a}`/`sub{$b}`)`
    
  }
    if (eql($format, latex)){
      if (not($within_math_scope)){
        $within_math_scope=true;
        `$\\frac{`$a`}{`$b`}$`
      }
      else{
        `\\frac{`$a`}{`$b`}`
      }
    }
}


$mult="×";
$plusmin="±";
$sqrt="√";
$noteq="≠";
$approxeq="≈";
$theta="θ";
$interrobang="‽";

if (eql($format, latex)){
  $mult = "\\(\\times\\)";
  $plusmn = "U+00B1";
  $sqrt ~ 
    if (not($within_math_scope)){"$"}
    "\\sqrt[]{}"
    if (not($within_math_scope)){"$"};
  $noteq ~ 
    if (not($within_math_scope)){"$"}
    "\\ne"
    if (not($within_math_scope)){"$"};
  $approxeq ~ 
    if (not($within_math_scope)){"$"}
    "\\approx"
    if (not($within_math_scope)){"$"};
  $theta ~ 
    if (not($within_math_scope)){"$"}
    "\\muptheta"
    if (not($within_math_scope)){"$"};
  $interrobang="!?";
}

"""

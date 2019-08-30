Tutorial: Validation
========

### Introduction

This tutorial will guide you through implementing input validation for the create and update forms in the blog site you built in the the [RESTful Blog tutorial](tutorial-restful-blog.md), using the validation plugin in the qcode-ui library. This assumes you have completed that tutorial and will add to the code you used there.

## qcode-ui

Up to now, you have made use of the qcode-tcl library - this tutorial will introduce a separate library: [qcode-ui](https://github.com/qcode-software/qcode-ui/tree/master). You may wish to look over its documentation before we begin.

Additionally, you should note that this library makes extensive use of [jQuery](https://learn.jquery.com/about-jquery/), a JavaScript library widely used in web development. If you are not familiar with it, the parts absolutely essential to this tutorial will be explained where they become relevant, but as the qcode-ui library as a whole makes extensive use of jQuery you would benefit from taking some time to learn more about it.

## Input validation

Input validation is an important feature on any site, necessary both for security and for a good user experience. Even in the simple blog site we have constructed as a learning exercise, deficient input validation can cause difficulty. To demonstrate this, try submitting a new entry with both the "Blog Title" and "Blog Content" fields left blank. You will notice there is now an empty line at the bottom of the list of links in your index page - if you use the inspector feature in your browser to view the HTML, you will see that there is in fact a link to your blank entry taking up space in the index, but because it has no title the link has no text and cannot be clicked. In order to view this useless entry and delete it, you will need to find its entry_id and navigate to its page by manually typing the URL into your address bar.

This inconvenience could have been avoided with even very crude input validation, which you will now add.

## Updating the database

Implementing some rudimentary validation to prevent blank entries is very straightforward. Simply open psql, and run the following commands:

```sql
alter table entries alter entry_title set not null;
alter table entries alter entry_content set not null;
```

Return to your browser and try submitting a blank entry. You will receive an error message, and your entry will not be saved. You have successfully implemented basic input validation - well done.

However, we can do a better job of it than this, and we will use the qcode-ui library's validation plugin to do so.

## Including the library

Before we proceed, you may wish to read through the [validation plugin's documentation](https://github.com/qcode-software/qcode-ui/blob/master/docs/forms/validation/validation.md). 

If we are to make use of the plugin, we must include the qcode-ui library when we serve our form page. Your `url_handlers.tcl` file should be unchanged since the end of the last tutorial. First, ensure your new entry form path handler matches the following:

```tcl
register GET /entries/new {} {
    #| Form for submitting new blog entry
    set form ""
    append form [h label "Blog Title:"]
    append form [h br]
    append form [h input type text name entry_title]
    append form [h br]
    append form [h label "Blog Content:"]
    append form [h br]
    append form [h textarea name entry_content style "width: 400px; height: 120px;"]
    append form [h br]
    append form [h input type submit name submit value Submit]
    append form [h br]
    append form [h br]
    append form [h a href "http://localhost/entries" "Return to index"]
    
    return [qc::form method POST action /entries $form]
}
```

### Restructuring our HTML

At present, your code assembles a form element and then returns it directly to be served to the client. We will be expanding the HTML we return to the client to include several JavaScript components from various sources. We will add them gradually. First, place the following line at the top of your path handler, immediately below the comment:

```tcl
    set html ""
```

This `html` variable will hold all of our HTML (including the form) and eventually be what is returned to the client. Therefore, we must also append our form to the `html` variable, and change our return statement to return `html` instead of just the form. Remove your current return statement, and insert the following in its place:

```tcl
    append html [qc::form method POST action /entries id "entry-form" $form]
    return $html
```
Note that we have now given the form an id property - this will be used later by our JavaScript to select the form element.

At present, our link back to the index page is placed inside the form element, as it was originally all we returned. Now that we have the `html` variable, it no longer makes sense to have this line inside the form element:

```tcl
    append form [h a href "http://localhost/entries" "Return to index"]
```

Move this line to be the last thing before we return the `html` variable, and change it so that the link is appended to `html` instead of `form`.

### Attaching our JavaScript

Now that we have rearranged our HTML, we are ready to begin adding JavaScript. Immediately after the assignment of the `html` variable, insert the following line:

```tcl
    append html [h script type "text/javascript" \
	   src "https://code.jquery.com/jquery-1.9.1.min.js"]
```

Our first script element imports the core jQuery library from a [CDN](https://en.wikipedia.org/wiki/Content_delivery_network) - we are placing this script first because some of our other scripts depend on it, and will return an error if it has not run already. Our next script will go directly below it:

```tcl
    append html [h script type "text/javascript" \
	   src "https://code.jquery.com/ui/1.9.2/jquery-ui.min.js"]
```

This script is the [jQuery UI library](https://jqueryui.com), which depends on jQuery and is itself depended on by the qcode-ui library. If you like, try temporarily moving the jQuery UI script element above the jQuery one - open your browser's developer tools and reload the page, and you should see `ReferenceError: jQuery is not defined` as a result of jQuery UI attempting to reference jQuery before it has been loaded in.

Next, we will add two more scripts that we will need before we can use the qcode-ui library. Add the following beneath your other scripts:

```tcl
    append html [h script type "text/javascript" \
           src "https://cdn.jsdelivr.net/npm/js-cookie@2/src/js.cookie.min.js"]
    append html [h script type "text/javascript" \
           src "https://cdnjs.cloudflare.com/ajax/libs/qtip2/3.0.3/jquery.qtip.min.js"]
```

The first script is an API used by qcode-ui to handle cookies. The latter is used by the validation plugin to insert tooltips highlighting useful information, such as reminding a user to enter a valid value in a form field.

Now that we have prepared all of its dependencies, we are ready to include qcode-ui. Beneath the other scripts, add the following:

```tcl
    append html [h script type "text/javascript" \
           src "https://d1ab3pgt4r9xn1.cloudfront.net/qcode-ui-4.34.0/js/qcode-ui.js"]
```

Reload the page, and use your browser's inspector - inside the head of your HTML, you should find all five scripts in their correct order. You now have access to the qcode-ui library, including its validation plugin.

## Using the validation plugin

However, you will notice that including the library and its dependencies has not had any immediately noticeable effect on our form page. We are missing one last script, in which we write our own JavaScript and make use of the library to perform validation on our form inputs. Unlike the previous ones, it must be placed after the form element, as it will attempt to select the form by id and this will fail if the form does not exist yet at the time the script is run. Place the following on the final line before you return your `html` variable:

```tcl
    append html [h script type "text/javascript" \
		     {$('#entry-form').validation({submit: false, messages: {error: {before: '#entry-form'}}});
    	        	 
    	        $('#entry-form').on('validationComplete', function(event) {
    	const response = event.response;
    	if (response.status === "valid") {
    	    $(this).validation('setValuesFromResponse', response);
    	    $(this).validation('showMessage', 'notify', 'Submitted');
    	} else {
    	    $(this).validation('showMessage', 'error', 'Invalid values');
    	}
    		});
    		}]
```


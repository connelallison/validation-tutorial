register GET /entries/new {} {
    #| Form for submitting new blog entry
    set html ""
    append html [h script type "text/javascript" \
	   src "https://code.jquery.com/jquery-1.9.1.min.js"]
    append html [h script type "text/javascript" \
	   src "https://code.jquery.com/ui/1.9.2/jquery-ui.min.js"]
    append html [h script type "text/javascript" \
	   src "https://cdn.jsdelivr.net/npm/js-cookie@2/src/js.cookie.min.js"]
    append html [h script type "text/javascript" \
	   src "https://cdnjs.cloudflare.com/ajax/libs/qtip2/3.0.3/jquery.qtip.min.js"]
    append html [h script type "text/javascript" \
	   src "https://d1ab3pgt4r9xn1.cloudfront.net/qcode-ui-4.34.0/js/qcode-ui.js"]


# \
# 	   integrity "sha256-wS9gmOZBqsqWxgIVgA8Y9WcQOa7PgSIX+rPA0VL2rbQ=" \
# 	   crossorigin "anonymous"
    
 # \
 #           integrity "sha256-eEa1kEtgK9ZL6h60VXwDsJ2rxYCwfxi40VZ9E0XwoEA=" \
 # 	   crossorigin "anonymous"

    # append html [h script type "text/javascript" src "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js"]
    # append html [h link rel stylesheet type "text/css" href "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css"]
    # append html [h link rel stylesheet type "text/css" href "https://js.qcode.co.uk/vendor/qtip/2.2.1/jquery.qtip.min.css"]
    # append html [h link rel stylesheet type "text/css" href "https://js.qcode.co.uk/qcode-ui-4.13.0/css/qcode-ui.css"]
    
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
    
    append html [qc::form method POST action /entries id "entry-form" $form]
    append html [h a href "http://localhost/entries" "Return to index"]
    append html [h script type "text/javascript" { \
		     $('#entry-form').validation({submit: false, messages: {error: {before: '#entry-form'}}});
    	        	 
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
    return $html
}

register POST /entries {entry_title entry_content} {
    #| Create a new blog entry
    set entry_id [entry_create $entry_title $entry_content]
    qc::response action redirect [qc::url "/entries/$entry_id"]
}

register GET /entries/:entry_id {entry_id} {
    #| View an entry
    return [entry_get $entry_id]
}

register GET /entries {} {
    #| List all entries
    return [entries_index]
}

register GET /entries/:entry_id/edit {entry_id} {
    #| Form for editing a specific blog entry
    db_1row {
        select
	entry_title,
	entry_content
	from
	entries
	where entry_id=:entry_id
    }
    set html ""
    append html [h script type "text/javascript" \
	   src "https://code.jquery.com/jquery-1.9.1.min.js"]
    append html [h script type "text/javascript" \
	   src "https://code.jquery.com/ui/1.9.2/jquery-ui.min.js"]
    append html [h script type "text/javascript" \
	   src "https://cdn.jsdelivr.net/npm/js-cookie@2/src/js.cookie.min.js"]
    append html [h script type "text/javascript" \
	   src "https://cdnjs.cloudflare.com/ajax/libs/qtip2/3.0.3/jquery.qtip.min.js"]
    append html [h script type "text/javascript" \
	   src "https://d1ab3pgt4r9xn1.cloudfront.net/qcode-ui-4.34.0/js/qcode-ui.js"]


# \
# 	   integrity "sha256-wS9gmOZBqsqWxgIVgA8Y9WcQOa7PgSIX+rPA0VL2rbQ=" \
# 	   crossorigin "anonymous"
    
 # \
 #           integrity "sha256-eEa1kEtgK9ZL6h60VXwDsJ2rxYCwfxi40VZ9E0XwoEA=" \
 # 	   crossorigin "anonymous"

    # append html [h script type "text/javascript" src "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js"]
    # append html [h link rel stylesheet type "text/css" href "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css"]
    # append html [h link rel stylesheet type "text/css" href "https://js.qcode.co.uk/vendor/qtip/2.2.1/jquery.qtip.min.css"]
    # append html [h link rel stylesheet type "text/css" href "https://js.qcode.co.uk/qcode-ui-4.13.0/css/qcode-ui.css"]
    
    set form ""
    append form [h label "Blog Title:"]
    append form [h input type text name entry_title value $entry_title]
    append form [h br]
    append form [h label "Blog Content:"]
    append form [h br]
    append form [h textarea name entry_content style "width: 400px; height: 120px;" $entry_content]
    append form [h br]
    append form [h input type hidden name _method value PUT]
    append form [h input type submit name submit value Update]
    append form [h br]
    append form [h br]
    
    append html [qc::form id "update-form" method POST action "/entries/$entry_id" $form]
    append form [h a href "http://localhost/entries" "Return to index"]    
    append html [h script type "text/javascript" { \
		     $('#update-form').validation({submit: false, messages: {error: {before: '#update-form'}}});
    	        	 
    	             $('#update-form').on('validationComplete', function(event) {
			 const response = event.response;
			 if (response.status === "valid") {
			     $(this).validation('setValuesFromResponse', response);
			     $(this).validation('showMessage', 'notify', 'Submitted');
			 } else {
			     $(this).validation('showMessage', 'error', 'Invalid values');
			 }
		     });
    		}]    
}

register PUT /entries/:entry_id {entry_id entry_title entry_content} {
    #| Update an entry
    entry_update $entry_id $entry_title $entry_content
    qc::response action redirect [qc::url "/entries/$entry_id"]
}

register DELETE /entries/:entry_id {entry_id} {
    #| Delete an entry
    entry_delete $entry_id
    ns_returnredirect [qc::url "/entries"]
}

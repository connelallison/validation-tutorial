proc entry_create {entry_title entry_content} {
    #| Create a new blog entry
    set entry_id [db_seq entry_id_seq]
    db_dml "insert into entries\
           [sql_insert entry_id entry_title entry_content]"
    return $entry_id
}

proc entry_get {entry_id} {
    #| Return html summary for this entry
    db_1row {
	select
	entry_title,
	entry_content
	from
	entries
	where entry_id=:entry_id
    }
    set html ""
    append html [h h1 $entry_title]
    append html [h div $entry_content]
    append html [h br]
    append html [h a href "http://localhost/entries/$entry_id/edit" "Edit this blog"]
    append html [h br]
    append html [form method DELETE action /entries/$entry_id \
		     [h input type submit name submit value "Delete this blog"]]    
    append html [h br]
    append html [h a href "http://localhost/entries/new" "Submit another blog"]
    append html [h br]
    append html [h a href "http://localhost/entries" "Return to index"]
    return $html
}

proc entries_index {} {
    #| Return html report listing links to view each entry
    set html ""
    append html [h h1 "All Entries"]
    append html [h br]
    db_foreach {
	select
	entry_id,
	entry_title 
	from entries
	order by entry_id asc
    } {
	append html [h a href "http://localhost/entries/$entry_id" $entry_title]
	append html [h br]
    }
    append html [h br]
    append html [h a href "http://localhost/entries/new" "Submit another blog"]
    
    return $html
}

proc entry_update {entry_id entry_title entry_content} {
    #| Update an entry
    db_dml "update entries \
            set [sql_set entry_title entry_content] \
            where entry_id=:entry_id"
    return $entry_id
}

proc entry_delete {entry_id} {
    #| Delete an entry
    db_dml "delete from entries where entry_id=:entry_id"
}

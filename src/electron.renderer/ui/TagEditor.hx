package ui;

class TagEditor {
	public var jEditor : js.jquery.JQuery;
	var onChange : Void->Void;
	var tags : data.Tags;
	var allValuesGetter : Void->Array<String>;
	var allowEditing : Bool;

	public function new(tags:data.Tags, onChange, allValuesGetter:Void->Array<String>, allowEditing=true) {
		this.tags = tags;
		this.onChange = onChange;
		this.allValuesGetter = allValuesGetter;
		this.allowEditing = allowEditing;

		jEditor = new J('<div class="tagEditor"/>');
		renderAll();
	}

	function renderAll() {
		jEditor.empty();

		for( k in tags.iterator() )
			createTag(k);

		var jButtons = new J('<div class="actions"/>');
		jButtons.appendTo(jEditor);
		if( allowEditing ) {
			// Create new tag
			var jAdd = new J('<button class="add dark"> <span class="icon add"/> </button>');
			jAdd.appendTo(jButtons);
			jAdd.click( _->{
				createInput();
				jEditor.append(jButtons);
			});
		}
		else if( tags.isEmpty() ) {
			// "No tag" label
			var jEmpty = new J('<span class="empty">(No tag selected)</span>');
			jEditor.prepend(jEmpty);
			jEmpty.click( ev->onRecallTag(ev) );
		}

		// Recall button
		if( allValuesGetter().length>0 ) {
			var jRecall = new J('<button class="recall dark"> <span class="icon recall"/> </button>');
			jRecall.appendTo(jButtons);
			jRecall.click( ev->onRecallTag(ev) );
		}
	}

	function onRecallTag(ev:js.jquery.Event) {
		var ctx = new ui.modal.ContextMenu(ev);
		for(v in allValuesGetter())
			ctx.add({
				label: L.untranslated(v),
				cb: ()->{
					tags.set(v);
					onChange();
				}
			});

	}

	function createTag(?jTarget:js.jquery.JQuery, k:String) {
		var jTag = new J('<div class="tag"> <div class="label">$k</div> </div>');
		if( jTarget!=null )
			jTarget.replaceWith(jTag);
		else
			jEditor.append(jTag);

		if( allowEditing )
			jTag.find(".label").click( _->{
				createInput(jTag, k);
			});

		var jDelete = new J('<button class="delete transparent"> <span class="icon clear"/> </button>');
		jDelete.appendTo(jTag);
		jDelete.click( _->{
			tags.unset(k);
			jTag.remove();
			onChange();
		});
	}


	function createInput(?jTarget:js.jquery.JQuery, k="") {
		var jInput = new J('<input type="text"/>');
		if( jTarget!=null ) {
			jInput.css({ width:jTarget.outerWidth()+"px" });
			jTarget.replaceWith(jInput);
		}
		else
			jEditor.append(jInput);

		var i = new form.input.StringInput(jInput, ()->k, v->{
			v = tags.cleanUpTag(v);
			if( v!=null && v!=k ) {
				tags.unset(k);
				if( !tags.has(v) )
					tags.set(v);
				jInput.blur();
				onChange();
			}
			else
				jInput.blur();
		});
		// jInput.focus( _->{
		// 	new ui.TypeSuggestion(jInput, allValuesGetter());
		// });
		jInput.blur( _->renderAll() );
		jInput.focus();
	}

}
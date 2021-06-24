(function(){

	let MenuTpl =
		'<div id="menu_{{_namespace}}_{{_name}}" class="menu{{#align}} align-{{align}}{{/align}}">' +
			'<div class="head"><span>{{{title}}}</span></div>' +
				'<div class="menu-items">' + 
					'{{#elements}}' +
						'<div class="menu-item {{#selected}}selected{{/selected}}">' +
							'{{{label}}}{{#isSlider}} : &lt;{{{sliderLabel}}}&gt;{{/isSlider}}' +
						'</div>' +
					'{{/elements}}' +
				'</div>'+
			'</div>' +
		'</div>'
	;

	window.DBFWCore_MENU       = {};
	DBFWCore_MENU.ResourceName = 'dbfw-menu-default';
	DBFWCore_MENU.opened       = {};
	DBFWCore_MENU.focus        = [];
	DBFWCore_MENU.pos          = {};

	DBFWCore_MENU.open = function(namespace, name, data) {

		if (typeof DBFWCore_MENU.opened[namespace] == 'undefined') {
			DBFWCore_MENU.opened[namespace] = {};
		}

		if (typeof DBFWCore_MENU.opened[namespace][name] != 'undefined') {
			DBFWCore_MENU.close(namespace, name);
		}

		if (typeof DBFWCore_MENU.pos[namespace] == 'undefined') {
			DBFWCore_MENU.pos[namespace] = {};
		}

		for (let i=0; i<data.elements.length; i++) {
			if (typeof data.elements[i].type == 'undefined') {
				data.elements[i].type = 'default';
			}
		}

		data._index     = DBFWCore_MENU.focus.length;
		data._namespace = namespace;
		data._name      = name;

		for (let i=0; i<data.elements.length; i++) {
			data.elements[i]._namespace = namespace;
			data.elements[i]._name      = name;
		}

		DBFWCore_MENU.opened[namespace][name] = data;
		DBFWCore_MENU.pos   [namespace][name] = 0;

		for (let i=0; i<data.elements.length; i++) {
			if (data.elements[i].selected) {
				DBFWCore_MENU.pos[namespace][name] = i;
			} else {
				data.elements[i].selected = false;
			}
		}

		DBFWCore_MENU.focus.push({
			namespace: namespace,
			name     : name
		});
		
		DBFWCore_MENU.render();
		$('#menu_' + namespace + '_' + name).find('.menu-item.selected')[0].scrollIntoView();
	};

	DBFWCore_MENU.close = function(namespace, name) {
		
		delete DBFWCore_MENU.opened[namespace][name];

		for (let i=0; i<DBFWCore_MENU.focus.length; i++) {
			if (DBFWCore_MENU.focus[i].namespace == namespace && DBFWCore_MENU.focus[i].name == name) {
				DBFWCore_MENU.focus.splice(i, 1);
				break;
			}
		}

		DBFWCore_MENU.render();

	};

	DBFWCore_MENU.render = function() {

		let menuContainer       = document.getElementById('menus');
		let focused             = DBFWCore_MENU.getFocused();
		menuContainer.innerHTML = '';

		$(menuContainer).hide();

		for (let namespace in DBFWCore_MENU.opened) {
			for (let name in DBFWCore_MENU.opened[namespace]) {

				let menuData = DBFWCore_MENU.opened[namespace][name];
				let view     = JSON.parse(JSON.stringify(menuData));

				for (let i=0; i<menuData.elements.length; i++) {
					let element = view.elements[i];

					switch (element.type) {
						case 'default' : break;

						case 'slider' : {
							element.isSlider    = true;
							element.sliderLabel = (typeof element.options == 'undefined') ? element.value : element.options[element.value];

							break;
						}

						default : break;
					}

					if (i == DBFWCore_MENU.pos[namespace][name]) {
						element.selected = true;
					}
				}

				let menu = $(Mustache.render(MenuTpl, view))[0];
				$(menu).hide();
				menuContainer.appendChild(menu);
			}
		}

		if (typeof focused != 'undefined') {
			$('#menu_' + focused.namespace + '_' + focused.name).show();
		}

		$(menuContainer).show();

	};

	DBFWCore_MENU.submit = function(namespace, name, data) {
		$.post('http://' + DBFWCore_MENU.ResourceName + '/menu_submit', JSON.stringify({
			_namespace: namespace,
			_name     : name,
			current   : data,
			elements  : DBFWCore_MENU.opened[namespace][name].elements
		}));
	};

	DBFWCore_MENU.cancel = function(namespace, name) {
		$.post('http://' + DBFWCore_MENU.ResourceName + '/menu_cancel', JSON.stringify({
			_namespace: namespace,
			_name     : name
		}));
	};

	DBFWCore_MENU.change = function(namespace, name, data) {
		$.post('http://' + DBFWCore_MENU.ResourceName + '/menu_change', JSON.stringify({
			_namespace: namespace,
			_name     : name,
			current   : data,
			elements  : DBFWCore_MENU.opened[namespace][name].elements
		}));
	};

	DBFWCore_MENU.getFocused = function() {
		return DBFWCore_MENU.focus[DBFWCore_MENU.focus.length - 1];
	};

	window.onData = (data) => {

		switch (data.action) {

			case 'openMenu': {
				DBFWCore_MENU.open(data.namespace, data.name, data.data);
				break;
			}

			case 'closeMenu': {
				DBFWCore_MENU.close(data.namespace, data.name);
				break;
			}

			case 'controlPressed': {

				switch (data.control) {

					case 'ENTER': {
						let focused = DBFWCore_MENU.getFocused();

						if (typeof focused != 'undefined') {
							let menu    = DBFWCore_MENU.opened[focused.namespace][focused.name];
							let pos     = DBFWCore_MENU.pos[focused.namespace][focused.name];
							let elem    = menu.elements[pos];

							if (menu.elements.length > 0) {
								DBFWCore_MENU.submit(focused.namespace, focused.name, elem);
							}
						}

						break;
					}

					case 'BACKSPACE': {
						let focused = DBFWCore_MENU.getFocused();

						if (typeof focused != 'undefined') {
							DBFWCore_MENU.cancel(focused.namespace, focused.name);
						}

						break;
					}

					case 'TOP': {

						let focused = DBFWCore_MENU.getFocused();

						if (typeof focused != 'undefined') {

							let menu = DBFWCore_MENU.opened[focused.namespace][focused.name];
							let pos  = DBFWCore_MENU.pos[focused.namespace][focused.name];

							if (pos > 0) {
								DBFWCore_MENU.pos[focused.namespace][focused.name]--;
							} else {
								DBFWCore_MENU.pos[focused.namespace][focused.name] = menu.elements.length - 1;
							}

							let elem = menu.elements[DBFWCore_MENU.pos[focused.namespace][focused.name]];

							for (let i=0; i<menu.elements.length; i++) {
								if (i == DBFWCore_MENU.pos[focused.namespace][focused.name]) {
									menu.elements[i].selected = true;
								} else {
									menu.elements[i].selected = false;
								}
							}

							DBFWCore_MENU.change(focused.namespace, focused.name, elem);
							DBFWCore_MENU.render();

							$('#menu_' + focused.namespace + '_' + focused.name).find('.menu-item.selected')[0].scrollIntoView();
						}

						break;

					}

					case 'DOWN' : {

						let focused = DBFWCore_MENU.getFocused();

						if (typeof focused != 'undefined') {
							let menu   = DBFWCore_MENU.opened[focused.namespace][focused.name];
							let pos    = DBFWCore_MENU.pos[focused.namespace][focused.name];
							let length = menu.elements.length;

							if (pos < length - 1) {
								DBFWCore_MENU.pos[focused.namespace][focused.name]++;
							} else {
								DBFWCore_MENU.pos[focused.namespace][focused.name] = 0;
							}

							let elem = menu.elements[DBFWCore_MENU.pos[focused.namespace][focused.name]];

							for (let i=0; i<menu.elements.length; i++) {
								if (i == DBFWCore_MENU.pos[focused.namespace][focused.name]) {
									menu.elements[i].selected = true;
								} else {
									menu.elements[i].selected = false;
								}
							}

							DBFWCore_MENU.change(focused.namespace, focused.name, elem);
							DBFWCore_MENU.render();

							$('#menu_' + focused.namespace + '_' + focused.name).find('.menu-item.selected')[0].scrollIntoView();
						}

						break;
					}

					case 'LEFT' : {

						let focused = DBFWCore_MENU.getFocused();

						if (typeof focused != 'undefined') {
							let menu = DBFWCore_MENU.opened[focused.namespace][focused.name];
							let pos  = DBFWCore_MENU.pos[focused.namespace][focused.name];
							let elem = menu.elements[pos];

							switch(elem.type) {
								case 'default': break;

								case 'slider': {
									let min = (typeof elem.min == 'undefined') ? 0 : elem.min;

									if (elem.value > min) {
										elem.value--;
										DBFWCore_MENU.change(focused.namespace, focused.name, elem);
									}

									DBFWCore_MENU.render();
									break;
								}

								default: break;
							}

							$('#menu_' + focused.namespace + '_' + focused.name).find('.menu-item.selected')[0].scrollIntoView();
						}

						break;
					}

					case 'RIGHT' : {

						let focused = DBFWCore_MENU.getFocused();

						if (typeof focused != 'undefined') {
							let menu = DBFWCore_MENU.opened[focused.namespace][focused.name];
							let pos  = DBFWCore_MENU.pos[focused.namespace][focused.name];
							let elem = menu.elements[pos];

							switch(elem.type) {
								case 'default': break;

								case 'slider': {
									if (typeof elem.options != 'undefined' && elem.value < elem.options.length - 1) {
										elem.value++;
										DBFWCore_MENU.change(focused.namespace, focused.name, elem);
									}

									if (typeof elem.max != 'undefined' && elem.value < elem.max) {
										elem.value++;
										DBFWCore_MENU.change(focused.namespace, focused.name, elem);
									}

									DBFWCore_MENU.render();
									break;
								}

								default: break;
							}

							$('#menu_' + focused.namespace + '_' + focused.name).find('.menu-item.selected')[0].scrollIntoView();
						}

						break;
					}

					default : break;

				}

				break;
			}

		}

	};

	window.onload = function(e){
		window.addEventListener('message', (event) => {
			onData(event.data);
		});
	};

})();
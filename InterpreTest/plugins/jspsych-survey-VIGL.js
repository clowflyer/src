/*
 * Example plugin template
 */

jsPsych.plugins["jspsych-survey-VIGL"] = (function() {

	var plugin = {};

	plugin.trial = function(display_element, trial) {

	// set default values for parameters
	//@@: trial.parameter = trial.parameter || 'default value';

	//** From survey-multi-choice
	var plugin_id_name = "jspsych-survey-VIGL";
    var plugin_id_selector = '#' + plugin_id_name;
    var _join = function( /*args*/ ) {
		var arr = Array.prototype.slice.call(arguments, _join.length);
		return arr.join(separator = '-');
    }

	//** From survey-text
	trial.preamble = typeof trial.preamble == 'undefined' ? "" : trial.preamble;
	if (typeof trial.rows == 'undefined') {
		trial.rows = [];
		for (var i = 0; i < trial.questions.length; i++) {
			trial.rows.push(1);
		}
	}
	if (typeof trial.columns == 'undefined') {
		trial.columns = [];
		for (var i = 0; i < trial.questions.length; i++) {
			trial.columns.push(40);
		}
	}

    // allow variables as functions
    // this allows any trial variable to be specified as a function
    // that will be evaluated when the trial runs. this allows users
    // to dynamically adjust the contents of a trial as a result
    // of other trials, among other uses. you can leave this out,
    // but in general it should be included
    trial = jsPsych.pluginAPI.evaluateFunctionParameters(trial);

	
	// show preamble text
    display_element.append($('<div>', {
		"id": 'jspsych-survey-text-preamble',
		"class": 'jspsych-survey-text-preamble'
    }));

    $('#jspsych-survey-text-preamble').html(trial.preamble);

    // add questions
    for (var i = 0; i < trial.questions.length; i++) {
		// create div
		display_element.append($('<div>', {
			"id": 'jspsych-survey-text-' + i,
			"class": 'jspsych-survey-text-question',
			"float": 'right'
		}));

		// add question text
		$("#jspsych-survey-text-" + i).append('<p class="jspsych-survey-text">' + trial.questions[i] + '</p>');

		//** Add Radio button
		// create option radio buttons
		for (var j = 0; j < trial.options[i].length; j++) {
			var option_id_name = _join(plugin_id_name, "option", i, j), 
				option_id_selector = '#' + option_id_name;

			// add radio button container
			$("#jspsych-survey-text-" + i).append($('<div>', {
				"id": option_id_name,
				"class": _join(plugin_id_name, 'option')
			}));

			// add label and question text
			var option_label = '<label class="' + plugin_id_name + '-text">' + trial.options[i][j] + '</label>';
			$(option_id_selector).append(option_label);

			// create radio button
			var input_id_name = _join(plugin_id_name, 'response', i);
			$(option_id_selector + " label").prepend('<input type="radio" name="' + input_id_name + '" value="' + trial.options[i][j] + '">');
		}

		// add text box
		$("#jspsych-survey-text-" + i).append('<textarea name="#jspsych-survey-text-response-' + i + '" cols="' + trial.columns[i] + '" rows="' + trial.rows[i] + '"></textarea>');
    }

    // add submit button
    display_element.append($('<button>', {
      'id': 'jspsych-survey-text-next',
      'class': 'jspsych-btn jspsych-survey-text'
    }));
    $("#jspsych-survey-text-next").html('Submit Answers');
	$("#jspsych-survey-text-next").click(function() {
		// measure response time
		var endTime = (new Date()).getTime();
		var response_time = endTime - startTime;

		// create object to hold responses
		var question_data = {};
		$("div.jspsych-survey-text-question").each(function(index) {
			var id = "Q" + index;
			var val1 = $(this).find("input:radio:checked").val();
			var val2 = $(this).children('textarea').val();
			var obje = {};
			obje[id] = val1+val2;
			$.extend(question_data, obje);
		});

		// save data
		var trialdata = {
			"rt": response_time,
			"responses": JSON.stringify(question_data)
		};

		display_element.html('');

		// next trial
		jsPsych.finishTrial(trialdata);
    });
	var startTime = (new Date()).getTime();
    };

	return plugin;
})();

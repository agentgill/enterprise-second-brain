{
  title: 'Anthropic',

  custom_action: true,
  custom_action_help: {
    learn_more_url: 'https://docs.anthropic.com/en/api/getting-started',
    learn_more_text: 'Anthropic API documentation',
    body: '<p>Build your own Anthropic action with a HTTP request. The request will ' \
      'be authorized with your Anthropic connection.</p>'
  },

  connection: {
    fields: [
      {
        name: 'api_key',
        label: 'API key',
        control_type: 'password',
        optional: false,
        hint: 'Log in to <a href="https://console.anthropic.com" target="_blank">' \
              'Anthropic console</a>. Settings > API Keys > Create Key > Enter a ' \
              'name for your API key. Your API key and secret will be displayed.'
      },
      {
        name: 'version',
        control_type: 'select',
        optional: false,
        default: '2023-06-01',
        options: [
          %w[2023-06-01 2023-06-01]
        ],
        toggle_hint: 'Select from list',
        toggle_field: {
          name: 'version',
          label: 'Version',
          type: 'string',
          control_type: 'text',
          toggle_hint: 'Use custom value',
          optional: false,
          hint: 'Enter the anthropic version number to be used, e.g. 2023-06-01<br>' \
                'See version history <a href="https://docs.anthropic.com/en/api/' \
                'versioning#version-history" target="_blank">here</a>.'
        }
      }
    ],
    authorization: {
      type: 'custom',

      apply: lambda do |connection|
        headers('x-api-key': connection['api_key'],
                'anthropic-version': connection['version'])
      end
    },
    base_uri: lambda do |_connection|
      'https://api.anthropic.com/'
    end
  },

  test: lambda do |_connection|
    get('v1/models').
      params(limit: 1).
      after_error_response(/.*/) do |_code, body, _header, message|
        error("#{message}: #{body}")
      end
  end,

  actions: {
    send_messages: {
      title: 'Send messages to models',
      subtitle: 'Converse with Anthropic models',
      description: lambda do |_input, picklist_label|
        "Sends a message to <span class='provider'>" \
        "#{picklist_label['model'] || 'model'}</span> " \
        'in <span class="provider">Anthropic</span>'
      end,
      help: lambda do |_input, picklist_label|
        {
          body: 'This action sends a message to Anthropic, and gathers a response using ' \
                "#{picklist_label['model']} model",
          learn_more_url: 'https://docs.anthropic.com/en/api/messages',
          learn_more_text: 'Learn more'
        }
      end,

      config_fields: [
        {
          name: 'model',
          optional: false,
          control_type: 'select',
          pick_list: 'model_list',
          hint: 'Select any Anthropic model, e.g. Claude 3 Haiku'
        },
        {
          name: 'message_type',
          control_type: 'select',
          pick_list: 'message_types',
          optional: false,
          hint: 'Choose the type of the message to send.'
        }
      ],

      input_fields: lambda do |object_definitions|
        object_definitions['send_messages_input']
      end,

      execute: lambda do |_connection, input, _eis, _eos|
        payload = call('payload_for_send_message', input)
        response = post('v1/messages', payload).
                   after_error_response(/.*/) do |_code, body, _header, message|
                     error("#{message}: #{body}")
                   end
        { response: response&.dig('content', 0, 'text') }
      end,

      output_fields: lambda do |object_definitions|
        object_definitions['send_messages_output']
      end,

      sample_output: lambda do |_connection, _input|
        {
          response: '<Anthropic Response>'
        }
      end
    },
    translate_text: {
      title: 'Translate text',
      subtitle: 'Translate text between languages',
      help: {
        body: 'This action translates inputted text into a different language. ' \
              'While other languages may be possible, languages not on the predefined ' \
              'list may not provide reliable translations.'
      },
      description: "Translate <span class='provider'>text</span> into a " \
                   "different language using <span class='provider'>Anthropic</span>",

      config_fields: [
        {
          name: 'model',
          optional: false,
          control_type: 'select',
          pick_list: 'model_list',
          hint: 'Select any Anthropic model, e.g. Claude 3 Haiku'
        }
      ],

      input_fields: lambda do |object_definitions|
        object_definitions['translate_text_input']
      end,

      execute: lambda do |_connection, input, _eis, _eos|
        payload = call('payload_for_translation', input)
        response = post('v1/messages', payload).
                   after_error_response(/.*/) do |_code, body, _header, message|
                     error("#{message}: #{body}")
                   end
        call('extract_parsed_response', response)
      end,

      output_fields: lambda do |object_definitions|
        object_definitions['translate_text_output']
      end,

      sample_output: lambda do |_connection, _input|
        {
          response: '<Anthropic Translation>'
        }
      end
    },
    summarize_text: {
      title: 'Summarize text',
      subtitle: 'Get a summary of the input text in configurable length',
      help: {
        body: 'This action summarizes inputted text into a shorter version. ' \
              'The length of the summary can be configured.'
      },
      description: "Summarize <span class='provider'>text</span> " \
                   "using <span class='provider'>Anthropic</span>",

      config_fields: [
        {
          name: 'model',
          optional: false,
          control_type: 'select',
          pick_list: 'model_list',
          hint: 'Select any Anthropic model, e.g. Claude 3 Haiku'
        }
      ],

      input_fields: lambda do |object_definitions|
        object_definitions['summarize_text_input']
      end,

      execute: lambda do |_connection, input, _eis, _eos|
        payload = call('payload_for_summarize', input)
        response = post('v1/messages', payload).
                   after_error_response(/.*/) do |_code, body, _header, message|
                     error("#{message}: #{body}")
                   end
        call('extract_parsed_response', response)
      end,

      output_fields: lambda do |object_definitions|
        object_definitions['summarize_text_output']
      end,

      sample_output: lambda do |_connection, _input|
        {
          response: '<Anthropic Answer>'
        }
      end
    },
    parse_text: {
      title: 'Parse text',
      subtitle: 'Extract structured data from freeform text',
      help: {
        body: 'This action helps process inputted text to find specific information ' \
              'based on defined guidelines. The processed information is then available ' \
              'as datapills.'
      },
      description: "Parse <span class='provider'>text</span> to find specific " \
                   "information using <span class='provider'>Anthropic</span>",

      config_fields: [
        {
          name: 'model',
          optional: false,
          control_type: 'select',
          pick_list: 'model_list',
          hint: 'Select any Anthropic model, e.g. Claude 3 Haiku'
        }
      ],

      input_fields: lambda do |object_definitions|
        object_definitions['parse_text_input']
      end,

      execute: lambda do |_connection, input, _eis, _eos|
        payload = call('payload_for_parse', input)
        response = post('v1/messages', payload).
                   after_error_response(/.*/) do |_code, body, _header, message|
                     error("#{message}: #{body}")
                   end
        call('extract_parsed_response', response)
      end,

      output_fields: lambda do |object_definitions|
        object_definitions['parse_text_output']
      end,

      sample_output: lambda do |_connection, input|
        (parse_json(input['object_schema'])&.
          each_with_object({}) do |key, hash|
            hash[key['name'].gsub(/^\d|\W/) { |word| "_ #{word.unpack('H*')}" }] = '<Sample text>'
          end || {})
      end
    },
    draft_email: {
      title: 'Draft email',
      subtitle: 'Generate an email based on user description',
      help: {
        body: 'This action generates an email and parses input into datapills ' \
              'containing a subject line and body for easy mapping into future recipe actions. ' \
              'Note that the body contains placeholder text for a salutation if this information ' \
              "isn't present in the email description."
      },
      description: "Generate draft <span class='provider'>email</span> " \
                   "in <span class='provider'>Anthropic</span>",

      config_fields: [
        {
          name: 'model',
          optional: false,
          control_type: 'select',
          pick_list: 'model_list',
          hint: 'Select any Anthropic model, e.g. Claude 3 Haiku'
        }
      ],

      input_fields: lambda do |object_definitions|
        object_definitions['draft_email_input']
      end,

      execute: lambda do |_connection, input, _eis, _eos|
        payload = call('payload_for_email', input)
        response = post('v1/messages', payload).
                   after_error_response(/.*/) do |_code, body, _header, message|
                     error("#{message}: #{body}")
                   end
        call('extract_generated_email_response', response)
      end,

      output_fields: lambda do |object_definitions|
        object_definitions['draft_email_output']
      end,

      sample_output: lambda do
        {
          subject: 'Sample email subject',
          body: 'This is a sample email body.'
        }
      end
    },
    categorize_text: {
      title: 'Categorize text',
      subtitle: 'Classify text based on user-defined categories',
      help: {
        body: 'This action chooses one of the categories that best fits the input text. ' \
              'The output datapill will contain the value of the best match category or error ' \
              'if not found. If you want to have an option for none, please configure it ' \
              'explicitly.'
      },
      description: "Classify <span class='provider'>text</span> based on " \
                   "user-defined categories using <span class='provider'>Anthropic</span>",

      config_fields: [
        {
          name: 'model',
          optional: false,
          control_type: 'select',
          pick_list: 'model_list',
          hint: 'Select any Anthropic model, e.g. Claude 3 Haiku'
        }
      ],

      input_fields: lambda do |object_definitions|
        object_definitions['categorize_text_input']
      end,

      execute: lambda do |_connection, input, _eis, _eos|
        payload = call('payload_for_categorization', input)
        response = post('v1/messages', payload).
                   after_error_response(/.*/) do |_code, body, _header, message|
                     error("#{message}: #{body}")
                   end
        call('extract_parsed_response', response)
      end,

      output_fields: lambda do |object_definitions|
        object_definitions['categorize_text_output']
      end,

      sample_output: lambda do |_connection, input|
        {
          'response' => input['categories']&.first&.[]('key') || 'N/A'
        }
      end
    },
    analyze_text: {
      title: 'Analyze text',
      subtitle: 'Contextual analysis of text to answer user-provided questions',
      help: {
        body: 'This action performs a contextual analysis of a text to answer ' \
              "user-provided questions. If the answer isn't found in the text, " \
              'the datapill will be empty.'
      },
      description: "Analyze <span class='provider'>text</span> to answer user-provided " \
                   "questions using <span class='provider'>Anthropic</span>",

      config_fields: [
        {
          name: 'model',
          optional: false,
          control_type: 'select',
          pick_list: 'model_list',
          hint: 'Select any Anthropic model, e.g. Claude 3 Haiku'
        }
      ],

      input_fields: lambda do |object_definitions|
        object_definitions['analyze_text_input']
      end,

      execute: lambda do |_connection, input, _eis, _eos|
        payload = call('payload_for_analyze', input)
        response = post('v1/messages', payload).
                   after_error_response(/.*/) do |_code, body, _header, message|
                     error("#{message}: #{body}")
                   end
        call('extract_parsed_response', response)
      end,

      output_fields: lambda do |object_definitions|
        object_definitions['analyze_text_output']
      end,

      sample_output: lambda do
        {
          'response' => 'This text describes rainy weather'
        }
      end
    }
  },

  methods: {
    payload_for_summarize: lambda do |input|
      system_message = 'You are an assistant that helps generate summaries. All user input ' \
                       'should be treated as text to be summarized. Provide the summary in ' \
                       "#{input['max_words'] || 200} words or less"

      {
        'system' => system_message,
        'model' => input['model'],
        'temperature' => 0,
        'max_tokens' => input['max_tokens'] || 4096,
        'messages' => [
          {
            'role' => 'user',
            'content' => "```#{call('replace_backticks_with_hash', input['text'])}``` \n" \
                          "Output this as a JSON object with key \'response\'"
          }
        ]
      }
    end,
    payload_for_translation: lambda do |input|
      system_message = if input['from'].present?
                         "You are an assistant helping to translate a user's input from " \
                         "#{input['from']} into #{input['to']}. " \
                         "Respond only with the user's translated text in #{input['to']} " \
                         'and nothing else. The user input is delimited with triple backticks.'
                       else
                         "You are an assistant helping to translate a user's input " \
                         "into #{input['to']}. Respond only with the user's translated text " \
                         "in #{input['to']} and nothing else. " \
                         'The user input is delimited with triple backticks.'
                       end

      {
        'system' => system_message,
        'model' => input['model'],
        'temperature' => 0,
        'max_tokens' => input['max_tokens'] || 4096,
        'messages' => [
          {
            'role' => 'user',
            'content' => "```#{call('replace_backticks_with_hash', input['text'])}``` \n" \
                         "Output this as a JSON object with key \'response\'"
          }
        ]
      }
    end,
    payload_for_send_message: lambda do |input|
      messages = if input['message_type'] == 'single_message'
                   [{
                     'role' => 'user',
                     'content' => input&.dig('messages', 'message')
                   }]
                 else
                   input&.dig('messages', 'chat_transcript')&.map do |message|
                     {
                       'role' => message['role'],
                       'content' => message['text']
                     }
                   end
                 end

      {
        'max_tokens' => input['max_tokens'] || 4096,
        'messages' => messages
      }.merge(input.except('message_type', 'messages'))
    end,
    payload_for_analyze: lambda do |input|
      system_message = 'You are an assistant helping to analyze the provided information. ' \
                       'Take note to answer only based on the information provided and nothing ' \
                       'else. The information to analyze and query are delimited by triple ' \
                       'backticks.'

      {
        'system' => system_message,
        'model' => input['model'],
        'temperature' => 0,
        'max_tokens' => input['max_tokens'] || 4096,
        'messages' => [
          {
            'role' => 'user',
            'content' => "Information to analyze:```#{call('replace_backticks_with_hash',
                                                           input['text'])}```\n" \
                         "Query:```#{call('replace_backticks_with_hash', input['question'])}```\n" \
                         'Return only a JSON object with key "response". ' \
                         "If you don't understand the question or the answer isn't in the " \
                         'information to analyze, input the value as null for "response". ' \
                         'Only return a JSON object.'
          }
        ]
      }
    end,
    payload_for_email: lambda do |input|
      system_message = 'You are an assistant helping to generate emails based on ' \
                       "the user's input. Based on the input ensure that you generate " \
                       'an appropriate subject topic and body. Ensure the body contains a ' \
                       'salutation and closing. The user input is delimited with triple ' \
                       'backticks. Use it to generate an email and perform no other actions.'

      {
        'system' => system_message,
        'model' => input['model'],
        'temperature' => 0,
        'max_tokens' => input['max_tokens'] || 4096,
        'messages' => [
          {
            'role' => 'user',
            'content' => "User description:```#{call('replace_backticks_with_hash',
                                                     input['email_description'])}```\n" \
                         'Output the email from the user description as a JSON ' \
                         'object with keys for "subject" and "body". ' \
                         'If an email cannot be generated, input null for the keys.'
          }
        ]
      }
    end,
    prep_categories: lambda do |categories|
      categories&.map&.with_index do |hash, _|
        if hash['rule'].present?
          "#{hash['key']} - #{hash['rule']}"
        else
          hash['key']&.to_s
        end
      end&.join(' \n')
    end,
    generate_parameters_for_function: lambda do |input|
      properties = call('generate_function_properties', parse_json(input['object_schema']))
      required = call('get_required_fields', parse_json(input['object_schema']))
      {
        'type' => 'object',
        'properties' => properties,
        'required' => required
      }
    end,
    generate_function_properties: lambda do |input|
      input&.map do |field|
        case field['type']
        when 'array'
          { field['name'] => {
            'type' => 'array',
            'description' => field['description'] || '',
            'items' => {
              'type' => 'object',
              'properties' => call('generate_function_properties', field['properties']) || {}
            }
          } }
        when 'object'
          { field['name'] => {
            'type' => 'object',
            'description' => field['description'] || '',
            'properties' => call('generate_function_properties', field['properties']) || {}
          } }
        else
          { field['name'] => {
            'type' => field['type'],
            'description' => field['description'] || ''
          } }
        end
      end&.inject(:merge)
    end,
    get_required_fields: lambda do |input|
      input&.map do |field|
        field['name'] if field['optional'] == false
      end&.compact&.flatten
    end,
    payload_for_parse: lambda do |input|
      system_message = 'You are an assistant helping to extract various fields of ' \
                       "information from the user's text. The text to parse is delimited " \
                       'by triple backticks.'

      {
        'system' => system_message,
        'model' => input['model'],
        'max_tokens' => input['max_tokens'] || 4096,
        'temperature' => 0,
        'tools' => [
          {
            'name' => 'text_details',
            'description' => 'Helps generate a summary based on the user provided text',
            'input_schema' => call('generate_parameters_for_function', input)
          }
        ],
        'tool_choice' => { 'type' => 'tool', 'name' => 'text_details' },
        'messages' => [
          {
            'role' => 'user',
            'content' => 'Text to parse: ```' \
                         "#{call('replace_backticks_with_hash', input['text']&.strip)}```\n" \
                         'Output the response as a JSON object with keys from the schema. ' \
                         'If no information is found for a specific key, the value should ' \
                         'be null. Only respond with a JSON object and nothing else.'
          }
        ]
      }
    end,
    payload_for_categorization: lambda do |input|
      categories = call('prep_categories', input['categories'])
      system_message = if input['categories'].all? { |arr| arr['rule'].present? }
                         'You are an assistant helping to categorize text into the various ' \
                         'categories mentioned. Respond with only the category name. The ' \
                         'categories and text to classify are delimited by triple backticks.' \
                         'The category information is provided as "Category name: Rule". Use ' \
                         'the rule to classify the text appropriately into one single category. ' \
                         'to identify the fields in the text.'
                       else
                         'You are an assistant helping to categorize text into the various ' \
                         'categories mentioned. Respond with only one category name. The ' \
                         'categories and text to classify are delimited by triple backticks.'
                       end

      {
        'system' => system_message,
        'model' => input['model'],
        'temperature' => 0,
        'max_tokens' => input['max_tokens'] || 4096,
        'messages' => [
          {
            'role' => 'user',
            'content' => "Categories:\n```#{categories}```\nText to classify: ```" \
                         "#{call('replace_backticks_with_hash', input['text']&.strip)}```\n" \
                         'Output the response as a JSON object with key "response". ' \
                         'If no category is found, the "response" value should be null. ' \
                         'Only respond with a JSON object and nothing else.'
          }
        ]
      }
    end,
    replace_backticks_with_hash: lambda do |text|
      text&.gsub('```', '####')
    end,
    extract_json: lambda do |resp|
      json_txt = resp&.dig('content', 0, 'text')
      json = json_txt&.gsub(/```json|```JSON|`+$/, '')&.strip
      parse_json(json) || {}
    end,
    extract_generic_response: lambda do |resp, is_json_response|
      answer = if is_json_response
                 call('extract_json', resp)&.[]('response')
               else
                 resp&.dig('content', 0, 'text')
               end
      {
        'response' => answer
      }
    end,
    extract_generated_email_response: lambda do |response|
      json = call('extract_json', response)
      {
        'subject' => json&.[]('subject'),
        'body' => json&.[]('body')
      }
    end,
    extract_parsed_response: lambda do |response|
      json = response&.dig('content', 0, 'input').presence || call('extract_json', response)
      json&.each_with_object({}) do |(key, value), hash|
        hash[key] = value
      end
    end,
    get_config_schema: lambda do
      [
        { name: 'max_tokens',
          control_type: 'integer',
          convert_input: 'integer_conversion',
          hint: 'The maximum number of tokens to generate before stopping. Different ' \
                'models have different maximum values for this parameter. See ' \
                "<a href='https://docs.anthropic.com/en/docs/about-claude/models' " \
                "target='_blank'>models</a> for details. If left blank, defaults to " \
                '4096.' },
        { name: 'stop_sequences',
          type: 'array',
          of: 'string',
          hint: 'A list of strings that will cause the model to stop generating.' },
        { name: 'temperature',
          control_type: 'number',
          convert_input: 'float_conversion',
          hint: "A number that controls the randomness of the model's output. " \
                'A higher temperature will result in more random output, while a ' \
                'lower temperature will result in more predictable output. ' \
                'Defaults to 1.0 if left blank.' },
        { name: 'top_p',
          label: 'Top P',
          control_type: 'number',
          convert_input: 'float_conversion',
          hint: 'A number that controls the probability of the model generating each token. ' \
                'A higher Top P will result in the model generating more likely tokens, ' \
                'while a lower Top P will result in the model generating more unlikely tokens.' },
        { name: 'top_k',
          label: 'Top K',
          control_type: 'integer',
          convert_input: 'integer_conversion',
          hint: 'A number that controls the number of tokens that the model considers when ' \
                'generating each token. A higher Top K will result in the model considering ' \
                'more tokens, while a lower Top K will result in the model considering ' \
                'fewer tokens.' },
        { name: 'metadata',
          type: 'object',
          properties: [
            { name: 'user_id',
              hint: 'An external identifier for the user who is associated with the request.' }
          ] },
        { name: 'stream',
          type: 'boolean',
          control_type: 'checkbox',
          convert_input: 'boolean_conversion',
          hint: 'Indicate whether to incrementally stream the response ' \
                'using server-sent events.',
          toggle_hint: 'Select from list',
          toggle_field: {
            name: 'stream',
            label: 'Stream',
            type: 'string',
            control_type: 'text',
            optional: true,
            convert_input: 'boolean_conversion',
            toggle_hint: 'Use custom value',
            hint: 'Allowed values: true or false.'
          } },
        { name: 'tool_choice',
          type: 'object',
          properties: [
            { name: 'type',
              control_type: 'select',
              extends_schema: true,
              sticky: true,
              pick_list: 'tool_choice_list',
              hint: 'How the model should use the provided tools. The model can ' \
                    'use a specific tool, any available tool, or decide by itself.',
              toggle_hint: 'Select sale layout',
              toggle_field: {
                name: 'type',
                type: 'string',
                label: 'Type',
                control_type: 'text',
                toggle_hint: 'Use custom value',
                optional: true,
                extends_schema: true,
                hint: 'Accepted values are: any, auto or tool.'
              } },
            { name: 'name',
              sticky: true,
              ngIf: 'input.tool_choice.type == "tool"',
              hint: 'The name of the tool to use.' },
            { name: 'disable_parallel_tool_use',
              type: 'boolean',
              control_type: 'checkbox',
              convert_input: 'boolean_conversion',
              hint: 'Defaults to false. If set to true, the model will ' \
                    'output at most one tool use.',
              toggle_hint: 'Select from list',
              toggle_field: {
                name: 'disable_parallel_tool_use',
                label: 'Disable parallel tool use',
                type: 'string',
                control_type: 'text',
                optional: true,
                convert_input: 'boolean_conversion',
                toggle_hint: 'Use custom value',
                hint: 'Allowed values: true or false.'
              } }
          ] },
        { name: 'tools',
          type: 'array',
          of: 'object',
          properties: [
            { name: 'name' },
            { name: 'description' },
            { name: 'input_schema',
              type: 'object',
              properties: [
                { name: 'schema_builder',
                  extends_schema: true,
                  control_type: 'schema-designer',
                  label: 'Schema',
                  sticky: true,
                  empty_schema_title: 'Describe all fields for your schema.',
                  hint: "Refer to <a href='https://docs.anthropic.com/en/api/messages' " \
                        "target='_blank'>tools definition</a> for examples.",
                  optional: true,
                  sample_data_type: 'json' }
              ] }
          ] },
        { name: 'system',
          hint: 'A system prompt is a way of providing context and instructions to Claude, ' \
                'such as specifying a particular goal or role.' },
        { name: 'thinking',
          type: 'object',
          hint: "When enabled, responses include thinking content blocks showing Claude's " \
                'thinking process before the final answer. Requires a minimum budget of ' \
                '1,024 tokens and counts towards your max tokens limit.<br><b>Thinking is only ' \
                'supported for Claude 3.7 Sonnet</b>.',
          properties: [
            { name: 'type',
              hint: 'This field is required when configuring extended thinking. ' \
                    'Allowed value: enabled' },
            { name: 'budget_tokens',
              control_type: 'integer',
              convert_input: 'integer_conversion',
              hint: 'Determines how many tokens Claude can use for its internal reasoning ' \
                    'process. Larger budgets can enable more thorough analysis for complex ' \
                    'problems, improving response quality. Must be ≥1024 and less than ' \
                    'max tokens. See <a href= "https://docs.anthropic.com/en/docs/build"' \
                    '"-with-claude/extended-thinking" target="_blank">extended thinking</a> ' \
                    'for details.' }
          ] }
      ]
    end
  },

  object_definitions: {
    analyze_text_input: {
      fields: lambda do |_connection, _config_fields, _object_definitions|
        [
          {
            name: 'text',
            label: 'Source text',
            type: 'string',
            hint: 'Provide the text to be analyzed.',
            optional: false
          },
          {
            name: 'question',
            label: 'Instruction',
            hint: 'Enter analysis instructions, such as an analysis ' \
            'technique or question to be answered.',
            optional: false
          }
        ].concat(call('get_config_schema').only('max_tokens'))
      end
    },
    analyze_text_output: {
      fields: lambda do |_connection, _config_fields, object_definitions|
        object_definitions['send_messages_output']
      end
    },
    draft_email_input: {
      fields: lambda do |_connection, _config_fields, _object_definitions|
        [
          {
            name: 'email_description',
            label: 'Email description',
            type: 'string',
            control_type: 'text-area',
            optional: false,
            hint: 'Enter a description for the email'
          }
        ].concat(call('get_config_schema').only('max_tokens'))
      end
    },
    draft_email_output: {
      fields: lambda do |_connection, _config_fields, _object_definitions|
        [
          {
            name: 'subject',
            label: 'Email subject',
            type: 'string'
          },
          {
            name: 'body',
            label: 'Email body',
            type: 'string'
          }
        ]
      end
    },
    categorize_text_input: {
      fields: lambda do |_connection, _config_fields, _object_definitions|
        [
          {
            name: 'text',
            label: 'Source text',
            type: 'string',
            control_type: 'text-area',
            optional: false,
            hint: 'Provide the text to be categorized'
          },
          {
            name: 'categories',
            control_type: 'key_value',
            label: 'List of categories',
            empty_list_title: 'List is empty',
            empty_list_text: 'Please add relevant categories',
            item_label: 'Category',
            extends_schema: true,
            type: 'array',
            of: 'object',
            optional: false,
            hint: 'Create a list of categories to sort the text into. Rules are ' \
            'used to provide additional details to help classify what each category represents',
            properties: [
              {
                name: 'key',
                label: 'Category',
                type: 'string',
                hint: 'Enter category name'
              },
              {
                name: 'rule',
                label: 'Rule',
                type: 'string',
                hint: 'Enter rule'
              }
            ]
          }
        ].concat(call('get_config_schema').only('max_tokens'))
      end
    },
    categorize_text_output: {
      fields: lambda do |_connection, _config_fields, _object_definitions|
        [
          {
            name: 'response',
            label: 'Best matching category',
            type: 'string'
          }
        ]
      end
    },
    parse_text_input: {
      fields: lambda do |_connection, _config_fields, _object_definitions|
        [
          {
            name: 'text',
            label: 'Source text',
            type: 'string',
            control_type: 'text-area',
            optional: false,
            hint: 'Provide the text to be parsed'
          },
          {
            name: 'object_schema',
            optional: false,
            control_type: 'schema-designer',
            extends_schema: true,
            sample_data_type: 'json_http',
            empty_schema_title: 'Provide output fields for your job output.',
            label: 'Fields to identify',
            hint: 'Enter the fields that you want to identify from the text. Add ' \
                  'descriptions for extracting the fields. Required fields take ' \
                  'effect only on top level. Nested fields are always optional.',
            exclude_fields: %w[hint label],
            exclude_fields_types: %w[integer date date_time],
            custom_properties: [
              {
                name: 'description',
                type: 'string',
                optional: true,
                label: 'Description'
              }
            ]
          }
        ].concat(call('get_config_schema').only('max_tokens'))
      end
    },
    parse_text_output: {
      fields: lambda do |_connection, config_fields, _object_definitions|
        parse_json(config_fields['object_schema'] || '[]')
      end
    },
    summarize_text_input: {
      fields: lambda do |_connection, _config_fields, _object_definitions|
        [
          {
            name: 'text',
            label: 'Source text',
            type: 'string',
            control_type: 'text-area',
            optional: false,
            hint: 'Provide the text to be summarized'
          },
          {
            name: 'max_words',
            label: 'Maximum words',
            type: 'integer',
            control_type: 'integer',
            optional: true,
            sticky: true,
            hint: 'Enter the maximum number of words for the summary. ' \
            'If left blank, defaults to 200.'
          }
        ].concat(call('get_config_schema').only('max_tokens'))
      end
    },
    summarize_text_output: {
      fields: lambda do |_connection, _config_fields, object_definitions|
        object_definitions['send_messages_output']
      end
    },
    translate_text_input: {
      fields: lambda do |_connection, _config_fields, _object_definitions|
        [
          {
            name: 'to',
            label: 'Output language',
            optional: false,
            control_type: 'select',
            pick_list: :languages_picklist,
            toggle_field: {
              name: 'to',
              control_type: 'text',
              type: 'string',
              optional: false,
              label: 'Output language',
              toggle_hint: 'Provide custom value',
              hint: 'Enter the output language. Eg. English'
            },
            toggle_hint: 'Select from list',
            hint: 'Select the desired output language'
          },
          {
            name: 'from',
            label: 'Source language',
            optional: true,
            sticky: true,
            control_type: 'select',
            pick_list: :languages_picklist,
            toggle_field: {
              name: 'from',
              control_type: 'text',
              type: 'string',
              optional: true,
              label: 'Source language',
              toggle_hint: 'Provide custom value',
              hint: 'Enter the source language. Eg. English'
            },
            toggle_hint: 'Select from list',
            hint: 'Select the source language. If this value is left blank, we will ' \
            'automatically attempt to identify it.'
          },
          {
            name: 'text',
            label: 'Source text',
            type: 'string',
            control_type: 'text-area',
            optional: false,
            hint: 'Enter the text to be translated. Please limit to 2000 tokens'
          }
        ].concat(call('get_config_schema').only('max_tokens'))
      end
    },
    translate_text_output: {
      fields: lambda do |_connection, _config_fields, object_definitions|
        object_definitions['send_messages_output']
      end
    },
    send_messages_input: {
      fields: lambda do |_connection, config_fields, _object_definitions|
        is_single_message = config_fields['message_type'] == 'single_message'
        message_schema = if is_single_message
                           [{
                             name: 'message',
                             label: 'Text to send',
                             type: 'string',
                             control_type: 'text-area',
                             optional: false,
                             hint: 'Enter a message to start a conversation with Anthropic.'
                           }]
                         else
                           [
                             {
                               name: 'system_role_message',
                               label: 'System role message',
                               type: 'string',
                               control_type: 'text-area',
                               optional: true,
                               hint: 'The contents of the system role message.'
                             },
                             {
                               name: 'chat_transcript',
                               label: 'Chat transcript',
                               type: 'array',
                               of: 'object',
                               optional: false,
                               properties: [
                                 {
                                   name: 'role',
                                   type: 'string',
                                   control_type: 'select',
                                   pick_list: :chat_role,
                                   optional: false,
                                   extends_schema: true,
                                   hint: 'Select the role of the author of this message.',
                                   toggle_field: {
                                     name: 'role',
                                     label: 'Role',
                                     control_type: 'text',
                                     type: 'string',
                                     optional: false,
                                     extends_schema: true,
                                     toggle_hint: 'Use custom value',
                                     hint: 'Provide the role of the author of this message. ' \
                                            'Allowed values: <b>user</b> or <b>model</b>.'
                                   },
                                   toggle_hint: 'Select from list'
                                 },
                                 {
                                   name: 'text',
                                   type: 'string',
                                   control_type: 'text-area',
                                   optional: false,
                                   hint: 'The contents of the selected role message.'
                                 }
                               ],
                               hint: 'A list of messages describing the conversation so far.'
                             }
                           ]
                         end
        [
          {
            name: 'messages',
            label: is_single_message ? 'Message' : 'Messages',
            type: 'object',
            optional: false,
            properties: message_schema
          }
        ].concat(call('get_config_schema'))
      end
    },
    send_messages_output: {
      fields: lambda do |_connection, _config_fields, _object_definitions|
        [
          {
            name: 'response',
            label: 'Anthropic reply'
          }
        ]
      end
    }
  },

  pick_lists: {
    model_list: lambda do
      get('v1/models')&.[]('data')&.map do |model|
        [model['display_name'], model['id']]
      end
    end,
    tool_choice_list: lambda do
      [
        %w[Any any],
        %w[Auto auto],
        %w[Tool tool]
      ]
    end,
    languages_picklist: lambda do
      [
        'Albanian', 'Arabic', 'Armenian', 'Awadhi', 'Azerbaijani', 'Bashkir', 'Basque',
        'Belarusian', 'Bengali', 'Bhojpuri', 'Bosnian', 'Brazilian Portuguese', 'Bulgarian',
        'Cantonese (Yue)', 'Catalan', 'Chhattisgarhi', 'Chinese', 'Croatian', 'Czech', 'Danish',
        'Dogri', 'Dutch', 'English', 'Estonian', 'Faroese', 'Finnish', 'French', 'Galician',
        'Georgian', 'German', 'Greek', 'Gujarati', 'Haryanvi', 'Hindi',
        'Hungarian', 'Indonesian', 'Irish', 'Italian', 'Japanese', 'Javanese', 'Kannada',
        'Kashmiri', 'Kazakh', 'Konkani', 'Korean', 'Kyrgyz', 'Latvian', 'Lithuanian',
        'Macedonian', 'Maithili', 'Malay', 'Maltese', 'Mandarin', 'Mandarin Chinese', 'Marathi',
        'Marwari', 'Min Nan', 'Moldovan', 'Mongolian', 'Montenegrin', 'Nepali', 'Norwegian',
        'Oriya', 'Pashto', 'Persian (Farsi)', 'Polish', 'Portuguese', 'Punjabi', 'Rajasthani',
        'Romanian', 'Russian', 'Sanskrit', 'Santali', 'Serbian', 'Sindhi', 'Sinhala', 'Slovak',
        'Slovene', 'Slovenian', 'Swedish', 'Ukrainian', 'Urdu', 'Uzbek', 'Vietnamese',
        'Welsh', 'Wu'
      ]
    end,
    message_types: lambda do
      %w[single_message chat_transcript].map { |type| [type.humanize, type] }
    end,
    chat_role: lambda do
      %w[assistant user].map { |role| [role.humanize, role] }
    end
  }
}
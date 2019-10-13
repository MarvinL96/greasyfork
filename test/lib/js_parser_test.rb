require 'test_helper'
require 'js_parser'

class JsParserTest < ActiveSupport::TestCase
  test '::get_meta_block' do
    js = <<~END
      // ==UserScript==
      // @name		A Test!
      // @description		Unit test.
      // ==/UserScript==
      var foo = "bar";
    END
    meta_block = JsParser.get_meta_block(js)
    expected_meta = <<~END
      // ==UserScript==
      // @name		A Test!
      // @description		Unit test.
      // ==/UserScript==
    END
    assert_equal expected_meta, meta_block
  end

  test '::get_meta_block no meta' do
    js = <<~END
      var foo = "bar";
    END
    meta_block = JsParser.get_meta_block(js)
    assert_nil meta_block
  end

  test '::parse_meta' do
    js = <<~END
      // ==UserScript==
      // @name		A Test!
      // @description		Unit test.
      // ==/UserScript==
      var foo = "bar";
    END
    meta = JsParser.parse_meta(js)
    assert_not_nil meta
    assert_equal 1, meta['name'].length
    assert_equal 'A Test!', meta['name'].first
    assert_equal 1, meta['description'].length
    assert_equal 'Unit test.', meta['description'].first
  end

  test '::parse_meta with no meta' do
    js = <<~END
      var foo = "bar";
    END
    meta = JsParser.parse_meta(js)
    assert_empty meta
  end

  test '::get_code_blocks' do
    js = <<~END
      // ==UserScript==
      // @name		A Test!
      // @description		Unit test.
      // @version 1.0
      // @namespace http://greasyfork.local/users/1
      // ==/UserScript==
      var foo = 'bar';
      foo.baz();
    END
    assert_equal ['', "\nvar foo = 'bar';\nfoo.baz();\n"], JsParser.get_code_blocks(js)
  end

  test '::get_code_blocks meta not at top' do
    js = <<~END
      var foo = 'bar';
      // ==UserScript==
      // @name		A Test!
      // @description		Unit test.
      // @version 1.0
      // @namespace http://greasyfork.local/users/1
      // ==/UserScript==
      foo.baz();
    END
    assert_equal ["var foo = 'bar';\n", "\nfoo.baz();\n"], JsParser.get_code_blocks(js)
  end

  test '::get_code_blocks with no meta' do
    js = <<~END
      var foo = 'bar';
      foo.baz();
    END
    assert_equal ["var foo = 'bar';\nfoo.baz();\n", ""], JsParser.get_code_blocks(js)
  end
end

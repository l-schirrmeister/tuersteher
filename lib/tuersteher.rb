# Module, welches AccesRules fuer Controller/Actions und
# Model-Object umsetzt.
#
# Die Regeln werden aus der Datei "config/acces_rules.rb" geladen
#
# Author: Bernd Ledig
#

require 'tuersteher/logger'
require 'tuersteher/access_rule_storage'
require 'tuersteher/access_rules'
require 'tuersteher/access_rule/base'
require 'tuersteher/access_rule/path'
require 'tuersteher/access_rule/model'
require 'tuersteher/access_rule/rule_extension/base'
require 'tuersteher/access_rule/rule_extension/user'
require 'tuersteher/access_rule/rule_extension/model'
require 'tuersteher/access_rule/specification/extension'
require 'tuersteher/access_rule/specification/method'
require 'tuersteher/access_rule/specification/model'
require 'tuersteher/access_rule/specification/path'
require 'tuersteher/access_rule/specification/role'
require 'tuersteher/extensions/controller_extensions'
require 'tuersteher/extensions/model_extensions'

module Tuersteher
end
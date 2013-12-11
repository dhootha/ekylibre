# = Informations
#
# == License
#
# Ekylibre - Simple ERP
# Copyright (C) 2009-2012 Brice Texier, Thibaud Merigon
# Copyright (C) 2012-2013 Brice Texier, David Joulin
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see http://www.gnu.org/licenses.
#
# == Table: product_memberships
#
#  created_at      :datetime         not null
#  creator_id      :integer
#  group_id        :integer          not null
#  id              :integer          not null, primary key
#  lock_version    :integer          default(0), not null
#  member_id       :integer          not null
#  nature          :string(255)      not null
#  operation_id    :integer
#  originator_id   :integer
#  originator_type :string(255)
#  started_at      :datetime         not null
#  stopped_at      :datetime
#  updated_at      :datetime         not null
#  updater_id      :integer
#
require 'test_helper'

class ProductMembershipTest < ActiveSupport::TestCase


end

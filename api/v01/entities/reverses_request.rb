# Copyright © Mapotempo, 2015
#
# This file is part of Mapotempo.
#
# Mapotempo is free software. You can redistribute it and/or
# modify since you respect the terms of the GNU Affero General
# Public License as published by the Free Software Foundation,
# either version 3 of the License, or (at your option) any later version.
#
# Mapotempo is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the Licenses for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with Mapotempo. If not, see:
# <http://www.gnu.org/licenses/agpl.html>
#
require './api/v01/entities/reverses_request_feature'


module Api
  module V01
    class ReversesRequest < Grape::Entity
      def self.entity_name
        'ReversesRequest'
      end

      expose(:reverses, using: ReversesRequestFeature, documentation: { type: ReversesRequestFeature, desc: 'Data to be reversed.', is_array: true, param_type: 'form' })
    end
  end
end

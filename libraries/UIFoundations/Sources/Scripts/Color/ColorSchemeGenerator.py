"""
	This python script aims to generate the colors in colorset with certain pattern dependence,
	and swift code for better use.

	* only supports from python3.6
	* requires dependence.json to do its job
	* to run this script:
		python3 ColorSchemeGenerator.py 'dependence_path' 'color_path' 'swift_path'
	* example:
		python3 ColorSchemeGenerator.py ColorDependence.json Assets.xcassets Colors

	## Parameters
		* 'dependence_path': the path that ColorDependence.json is
		* 'color_path': the directory for the colors to store, as the 'Assets.xcassets' in your project
		* 'swift_path': the directory for swift code, including 'Color.swift', 'ColorManager.swift', and 'UIColorManager.swift'

	## Color Dependence
		Group of colors:
			name
			colors:
				light_mode:
					alpha?
					red?
					green?
					blue?
					color_name?	# the dependent color
				dark_mode? # same format as light_mode

	## Dependence
		Light mode: This script will fetch the light_mode color until there's actual data ( rgb ) for it
		Dark mode: Unlike light mode, it will try to get drak mode's actual data. When it's null, then it'll turn to light mode for it.
		All will fetch til there's no dependence, `color_name` reference, anymore.

		*** Requiring the dependent one in front ***

	## Swift code
		*	'Color.swift' - declaration of two public enums: 'ColorManager' and 'UIColorManager'
		*	'ColorManager.swift' - the extension of enum, 'ColorManager,' which contains the declaration of colors for swiftUI
		* 'UIColorManager.swift' - the extension of enum, 'UIColorManager,' which contains the declaration of colors for UIKit
	
	## Knwon issue
		* Not handling the hash for Xcode to recognize the files, so one has to add them manually
"""

import os
import sys
import json

def createDirectoryIfNeeded( filename ):
	if not os.path.exists(os.path.dirname(filename)):
		try:
				os.makedirs(os.path.dirname(filename))
		except OSError as exc: # Guard against race condition
				if exc.errno != errno.EEXIST:
						raise



def main( argv ):
	# check argument length
	if len( argv ) != 3:
		print( """Wrong argument format. Format should be:
	python3 ColorSchemeGenerator.py 'dependence_path' 'color_path' 'swift_path'

For example:
	python3 ColorSchemeGenerator.py ColorDependence.json Assets.xcassets Colors

Please take a look of the top comment in this python file for more details.""")
		sys.exit(2)

	# load & decode json file
	color_dependence_path = argv[0]
	color_dependence = open(color_dependence_path)
	raw_data = color_dependence.read()
	data = json.loads(raw_data)

	# prepare output file pathes
	color_path = argv[1]
	swift_path = argv[2]
	enum_output_path = swift_path + "/Color.swift"
	swiftUI_output_path = swift_path + "/ColorManaer.swift"
	UIKit_output_path = swift_path + "/UIColorManager.swift"

	# prepare the text for output

	# prefix for all text
	text_prefix = """//
//  PMColors.swift
//  ProtonMail - Created on 04.11.20.
//
//  Copyright (c) 2020 Proton Technologies AG
//
//  This file is part of ProtonMail.
//
//  ProtonMail is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  ProtonMail is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonMail.  If not, see <https://www.gnu.org/licenses/>.
//
"""

	# for Color.swift
	enum_text = text_prefix + """

import Foundation

/// Only for UIKit
public enum UIColorManager {}

/// Only for SwiftUI
public enum ColorManager {}

"""
	# for ColorManager.swift
	swiftUI_text = text_prefix + """

import SwiftUI

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
extension ColorManager {

"""
	# for UIColorManager.swift
	UIKit_text = text_prefix + """

import UIKit

@available(iOS 11.0, *)
extension UIColorManager {
"""

	# cache colors in order to find the dependent color
	cached_color = dict()

	# the format for float number, should at least have one number after comma. Otherwise, Xcode won't recognize it.
	float_format = '.3f'

	# for each group in color scheme e.g. Text, Blenders, Background, etc.
	for group in data:
		group_folder = color_path + "/" + group["name"]

		mark_comment = f"""
\t// MARK: {group["name"]}
"""
		swiftUI_text += mark_comment
		UIKit_text += mark_comment

		for color in group["colors"]:
			filename = group_folder + "/" + color["name"] + ".colorset/Contents.json"

			swiftUI_text += f'\tpublic static let {color["name"]} = Color("{color["name"]}", bundle: PMUIFoundations.bundle)\n'
			UIKit_text += f'\tpublic static let {color["name"]} = UIColor(named: "{color["name"]}, in: PMUIFoundations.bundle, compatibleWith: nil)!\n'

			# find the final color in rgb representation
			# following the pattern as described on top comment
			light_mode_color_data = color["light_mode"]
			while "alpha" not in light_mode_color_data:
				light_mode_color_data = cached_color[ light_mode_color_data["color_name"] ] [ "light_mode" ]

			dark_mode_color_data = color["dark_mode"] if "dark_mode" in color else color["light_mode"]
			while "alpha" not in dark_mode_color_data:
				next_color = cached_color[ dark_mode_color_data["color_name"] ]
				dark_mode_color_data = next_color["dark_mode"] if "dark_mode" in next_color else next_color["light_mode"]
      

			# prepare the text for color's content.json
			text = f"""{{
  "colors" : [
  {{
    "color" : {{
      "color-space" : "srgb",
        "components" : {{
          "alpha" : "{ format(light_mode_color_data["alpha"], float_format )}",
          "blue" : "{ format(light_mode_color_data["blue"], float_format ) }",
          "green" : "{ format(light_mode_color_data["green"], float_format ) }",
          "red" : "{ format(light_mode_color_data["red"], float_format ) }"
        }}
    }},
      "idiom" : "universal"
  }},
  {{
    "appearances" : [
    {{
      "appearance" : "luminosity",
      "value" : "dark"
     }}
    ],
    "color" : {{
      "color-space" : "srgb",
      "components" : {{
        "alpha" : "{ format(dark_mode_color_data["alpha"], float_format ) }",
        "blue" : "{ format(dark_mode_color_data["blue"], float_format ) }",
        "green" : "{ format(dark_mode_color_data["green"], float_format ) }",
        "red" : "{ format(dark_mode_color_data["red"], float_format ) }"
      }}
    }},
    "idiom" : "universal"
   }}
  ],
  "info" : {{
    "author" : "xcode",
    "version" : 1
  }}
 }}
"""

			# write content.json according to Assets's file structure: Assets.xcassets/.../ColorName/content.json
			createDirectoryIfNeeded( filename )
			with open(filename, "w") as f:
				f.write(text)

			cached_color[ color["name"] ] = color


	# add the final closure 
	swiftUI_text +=  """
}
"""
	UIKit_text += """
}
"""

	# check if there's directory in front
	if '/' in enum_output_path:
		createDirectoryIfNeeded( enum_output_path )

	# write Color.swift
	with open(enum_output_path, "w") as f:
		f.write(enum_text)

	# check if there's directory in front
	if '/' in swiftUI_output_path:
		createDirectoryIfNeeded( swiftUI_output_path )

	# write ColorManager.swift
	with open(swiftUI_output_path, "w") as f:
		f.write(swiftUI_text)

	# check if there's directory in front
	if '/' in UIKit_output_path:
		createDirectoryIfNeeded( UIKit_output_path )

	# write UIColorManager.swift
	with open(UIKit_output_path, "w") as f:
		f.write(UIKit_text)

# end of main func

if __name__ == "__main__":
   main(sys.argv[1:])

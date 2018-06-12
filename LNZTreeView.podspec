Pod::Spec.new do |s|

    s.platform = :ios
    s.version = "1.1.0"
    s.ios.deployment_target = '8.0'
    s.name = "LNZTreeView"
 	s.summary      = "A swift TreeView implementation for iOS."

  	s.description  = <<-DESC
                   This is a swift implementation for iOS of a Tree View. A Tree View is a graphical representation of a tree. Each element (node) can have a number of sub elements (children).

                   This particular implementation of TreeView organizes nodes and subnodes in rows and each node has an indentation that indicates the hierarchy of the element. A parent can be expanded or collapsed and each children can be a parent itself containing more sub nodes.
                   DESC
                   
    s.requires_arc = true

    s.license = { :type => "MIT" }
	s.homepage = "https://www.pfrpg.net"
    s.author = { "Giuseppe Lanza" => "gringoire986@gmail.com" }
    s.source = {
        :git => "https://github.com/gringoireDM/LNZTreeView.git",
        :tag => "v1.1.0"
    }

    s.framework = "UIKit"

    s.source_files = "LNZTreeView/**/*.{swift, h}"
end
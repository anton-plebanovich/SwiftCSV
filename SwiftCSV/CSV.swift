//
//  CSV.swift
//  SwiftCSV
//
//  Created by Naoto Kaneko on 2/18/16.
//  Copyright © 2016 Naoto Kaneko. All rights reserved.
//

import Foundation

public protocol CSVView {
    associatedtype Rows
    associatedtype Columns

    var rows: Rows { get }
    var columns: Columns { get }

    init(header: [String], text: String, delimiter: Character, limitTo: Int?, loadColumns: Bool) throws
}

open class CSV {
    static public let comma: Character = ","
    
    public let header: [String]

    var text: String
    var delimiter: Character

    let loadColumns: Bool
    
    public func getNamedRows() throws -> [[String : String]] {
        let namedView = try NamedView(
            header: self.header,
            text: self.text,
            delimiter: self.delimiter,
            loadColumns: self.loadColumns)
        
        return namedView.rows
    }
    
    public func getNamedColumns() throws -> [String : [String]] {
        let namedView = try NamedView(
            header: self.header,
            text: self.text,
            delimiter: self.delimiter,
            loadColumns: self.loadColumns)
        
        return namedView.columns
    }

    /// Load CSV data from a string.
    ///
    /// - parameter string: CSV contents to parse.
    /// - parameter delimiter: Character used to separate  row and header fields (default is ',')
    /// - parameter loadColumns: Whether to populate the `columns` dictionary (default is `true`)
    /// - throws: `CSVParseError` when parsing `string` fails.
    public init(string: String, delimiter: Character = comma, loadColumns: Bool = true) throws {
        self.text = string
        self.delimiter = delimiter
        self.loadColumns = loadColumns
        self.header = try Parser.array(text: string, delimiter: delimiter, rowLimit: 1).first ?? []
    }

    @available(*, deprecated, message: "Use init(url:delimiter:encoding:loadColumns:) instead of this path-based approach. Also, calling the parameter `name` instead of `path` was a mistake.")
    public convenience init(name: String, delimiter: Character = comma, encoding: String.Encoding = .utf8, loadColumns: Bool = true) throws {
        try self.init(url: URL(fileURLWithPath: name), delimiter: delimiter, encoding: encoding, loadColumns: loadColumns)
    }

    /// Load a CSV file as a named resource from `bundle`.
    ///
    /// - parameter name: Name of the file resource inside `bundle`.
    /// - parameter ext: File extension of the resource; use `nil` to load the first file matching the name (default is `nil`)
    /// - parameter bundle: `Bundle` to use for resource lookup (default is `.main`)
    /// - parameter delimiter: Character used to separate row and header fields (default is ',')
    /// - parameter encoding: encoding used to read file (default is `.utf8`)
    /// - parameter loadColumns: Whether to populate the columns dictionary (default is `true`)
    /// - throws: `CSVParseError` when parsing the contents of the resource fails, or file loading errors.
    /// - returns: `nil` if the resource could not be found
    public convenience init?(name: String, extension ext: String? = nil, bundle: Bundle = .main, delimiter: Character = comma, encoding: String.Encoding = .utf8, loadColumns: Bool = true) throws {
        guard let url = bundle.url(forResource: name, withExtension: ext) else {
            return nil
        }
        try self.init(url: url, delimiter: delimiter, encoding: encoding, loadColumns: loadColumns)
    }
    
    /// Load a CSV file from `url`.
    ///
    /// - parameter url: URL of the file (will be passed to `String(contentsOfURL:encoding:)` to load)
    /// - parameter delimiter: Character used to separate row and header fields (default is ',')
    /// - parameter encoding: Character encoding to read file (default is `.utf8`)
    /// - parameter loadColumns: Whether to populate the columns dictionary (default is `true`)
    /// - throws: `CSVParseError` when parsing the contents of `url` fails, or file loading errors.
    public convenience init(url: URL, delimiter: Character = comma, encoding: String.Encoding = .utf8, loadColumns: Bool = true) throws {
        let contents = try String(contentsOf: url, encoding: encoding)
        
        try self.init(string: contents, delimiter: delimiter, loadColumns: loadColumns)
    }
    
    /// Turn the CSV data into NSData using a given encoding
    open func dataUsingEncoding(_ encoding: String.Encoding) -> Data? {
        return description.data(using: encoding)
    }
}

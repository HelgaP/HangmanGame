//
//  Result.swift
//  HangmanProject
//
//  Created by Irina Perepelkina on 15.05.2021.
//  Copyright © 2021 Irina Perepelkina. All rights reserved.
//

import Foundation

enum Result<ResultType> {
    case success(ResultType)
    case failure(Error)
}

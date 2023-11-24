//
//  Observable+Retry.swift
//  CoreUtils
//
//  Created by Thanh Vu on 18/10/2021.
//

import Foundation
import RxSwift

public extension Observable {
    func retry(count: Int = 1, when: @escaping (Error) -> Bool) -> Observable<Element> {
        var remainRetry = count
        return retryWhen { observableError in
            observableError.flatMap { error -> Observable<()> in
                if remainRetry > 0 {
                    remainRetry -= 1
                    return when(error) ? Observable<()>.just(()) : Observable<()>.error(error)
                }

                return Observable<()>.error(error)
            }
        }
    }
}

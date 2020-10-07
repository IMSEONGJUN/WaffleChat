//
//  WaffleChatTests.swift
//  WaffleChatTests
//
//  Created by SEONGJUN on 2020/10/07.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import XCTest
import Foundation
import RxSwift
import RxCocoa
import Firebase
@testable import WaffleChat

class WaffleChatTests: XCTestCase {

    let disposeBag = DisposeBag()
    let api = APIManager.shared
    

    override func setUpWithError() throws {
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFetchCurrentUser() {
        let currentUId = Auth.auth().currentUser?.uid
        api.fetchUser(uid: currentUId ?? "")
            .subscribe(onNext: {
                guard let user = $0 else { return }
                XCTAssertTrue(user.uid == currentUId)
            })
            .disposed(by: disposeBag)
    }
    
    
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}

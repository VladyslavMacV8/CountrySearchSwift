//
//  Presenter.swift
//  CountrySearch
//
//  Created by Vladyslav Kudelia on 10/10/18.
//  Copyright © 2018 Vladyslav Kudelia. All rights reserved.
//

import UIKit

final class PresenterImpl: Presenter {
    
    private let storyboard = AppStoryboard.Main.instance
    private let router: Router
    
    init() {
        guard let root = UIApplication.topCustomViewController() as? CustomTabBarController else {
            fatalError("Could not init stack")
        }
        
        router = RouterImpl(rootController: root)
    }
    
    func openAlertVCForError(_ alert: UIAlertController) {
        router.openAlertViewController(alertViewController: alert)
    }
    
    func openCountriesVC(_ title: String, _ value: [CountryEntity], _ state: CountryVCState) {
        let vc = CountriesViewController.instantiate(from: .Main)
        vc.title = title
        vc.viewModel.countries = value
        vc.state = state
        router.push(controller: vc, animated: true)
    }
    
    func openDetailVC(_ value: CountryEntity, _ state: CountryVCState) {
        let vc = DetailCountryViewController.instantiate(from: .Main)
        vc.title = value.name
        vc.viewModel.country = value
        vc.state = state
        router.push(controller: vc, animated: true)
    }
    
    func popVCAfterDeleteData() {
        router.popController(animated: true)
    }
}

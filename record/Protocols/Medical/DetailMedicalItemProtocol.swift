//
//  DetailMedicalItemPresenter.swift
//  record
//
//  Created by Esakkinathan B on 26/02/26.
//
import UIKit

protocol DetailMedicalItemPresenterProtocol {
    var title: String { get }
    func numberOfSection() -> Int
    func numberOfSectionRows(at section: Int) -> Int
    func section(at indexPath: IndexPath) -> DetailMedicalRow
    func getTitle(for section: Int) -> String?
    func viewDidLoad()


}

protocol DetailMedicalItemViewDelegate: AnyObject {
    func reloadData()

}

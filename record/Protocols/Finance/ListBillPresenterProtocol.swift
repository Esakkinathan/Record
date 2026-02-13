//
//  ListBillPresenterProtocol.swift
//  record
//
//  Created by Esakkinathan B on 12/02/26.
//
import VTDB

protocol ListBillPresenterProtocol {
    var title: String { get }
    func numberOfRows() -> Int
    func bill(at index: Int) -> Bill
    func deleteBill(at index: Int)
    func editBill(at index: Int)
    func gotoAddBillScreen()
    func billContent(at index: Int) -> BillContent
    func viewDidLoad()
    func markAsPaidClicked(at index: Int)

}

protocol ListBillViewDelegate: AnyObject {
    func reloadData()
    func reloadField(at index: Int)
    func openMarkAsPaidAlert(completion: @escaping (Date) -> Void)
}

protocol ListBillRouterProtocol {
func openAddBillVC(mode: BillFormMode, utilityAccountId: Int, type: BillType,onChange: @escaping (Persistable) -> Void)
//    func openEditBillVC(mode: BillFormMode, utilityAccoundId: Int, type: BillType, onEdit: @escaping (Bill) -> Void)

}

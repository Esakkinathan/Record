//
//  ListBillPresenter.swift
//  record
//
//  Created by Esakkinathan B on 12/02/26.
//

import Foundation

struct  BillContent {
    let text1: String
    let text2: String
    let value: Bool
}

class ListBillPresenter: ListBillPresenterProtocol {
    
    weak var view: ListBillViewDelegate?
    
    let router: ListBillRouterProtocol
    
    let billType: BillType
    
    var title: String {
        billType.rawValue
    }
    let addUseCase: AddBillUseCaseProtocol
    let updateUseCase: UpdateBillUseCaseProtocol
    let deleteUseCase: DeleteBillUseCaseProtocl
    let fetchUseCase: FetchBillUseCaseProtocol
    let markAsPaidUseCase: MarkAsPaidUseCaseProtocol
    var bills: [Bill] = []
    
    var utilityAccount: UtilityAccount
    
    init(view: ListBillViewDelegate? = nil, router: ListBillRouterProtocol, billType: BillType, addUseCase: AddBillUseCaseProtocol, updateUseCase: UpdateBillUseCaseProtocol, deleteUseCase: DeleteBillUseCaseProtocl, fetchUseCase: FetchBillUseCaseProtocol, markAsPaidUseCase: MarkAsPaidUseCaseProtocol,utilityAccount: UtilityAccount) {
        self.view = view
        self.router = router
        self.billType = billType
        self.addUseCase = addUseCase
        self.updateUseCase = updateUseCase
        self.deleteUseCase = deleteUseCase
        self.fetchUseCase = fetchUseCase
        self.markAsPaidUseCase = markAsPaidUseCase
        self.utilityAccount = utilityAccount
    }
    
    func viewDidLoad() {
        loadBills()
    }
    func loadBills() {
        bills = fetchUseCase.execute(utilityAccountId: utilityAccount.id, billType: billType)
    }

    func reloadDataAndView() {
        loadBills()
        view?.reloadData()
    }

    func numberOfRows() -> Int {
        return bills.count
    }
    
    func bill(at index: Int) -> Bill {
        return bills[index]
    }
    
    func billContent(at index: Int) -> BillContent {
        let bill = bill(at: index)
        let text1: String
        let text2: String
        let value: Bool
        switch billType {
            
        case .ongoing:
            if let notes = bill.notes {
                text2 = notes
                text1 = "Amount: \(bill.amount) Due date: \(bill.dueDate?.toString() ?? "")"
            } else {
                text1 = "\(bill.amount)"
                text2 = "Due date: \(bill.dueDate?.toString() ?? "")"
            }
            value = false
        case .completed:
            if let notes = bill.notes {
                text2 = notes
                text1 = " Amount: \(bill.amount) Paid date: \(bill.paidDate?.toString() ?? "")"
            } else {
                text1 = "\(bill.amount)"
                text2 = "Paid date: \(bill.paidDate?.toString() ?? "")"
            }
            value = true

        }
        return BillContent(text1: text1, text2: text2, value: value)
    }
    
    func addBill(_ bill: Bill) {
        addUseCase.execute(bill: bill)
        reloadDataAndView()
    }
    
    func updateBill(_ bill: Bill) {
        updateUseCase.execute(bill: bill)
        reloadDataAndView()
    }
    
    func deleteBill(at index: Int) {
        let bill = bill(at: index)
        deleteUseCase.execute(id: bill.id)
        reloadDataAndView()
    }
    
    func editBill(at index: Int) {
        let bill = bill(at: index)
        router.openAddBillVC(mode: .edit(bill), utilityAccountId: utilityAccount.id, type: billType){ [weak self] updatedBill in
            self?.updateBill(updatedBill as! Bill)
        }
    }
    
    func markAsPaidForBill(bill: Bill, paidDate: Date) {
        bill.markAsPaid(paidDate: paidDate)
        markAsPaidUseCase.execute(bill: bill, paidDate: paidDate)
        reloadDataAndView()
    }
    
    func markAsPaidClicked(at index: Int) {
        let bill = bill(at: index)
        view?.openMarkAsPaidAlert(){ [weak self] date in
            self?.markAsPaidForBill(bill: bill, paidDate: date)
            //self?.reloadDataAndView()
        }
    }
    
    func gotoAddBillScreen() {
        router.openAddBillVC(mode: .add, utilityAccountId: utilityAccount.id, type: billType) { [weak self] bill in
            self?.addBill(bill as! Bill)
            
        }
    }
        
}

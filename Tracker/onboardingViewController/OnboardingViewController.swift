

import UIKit

class OnboardingViewController: UIPageViewController {
    
    private let buttom: UIButton = {
        let buttom = UIButton()
        buttom.backgroundColor = .black
        buttom.tintColor = .white
        buttom.titleLabel?.text = "Вот это технологии!"
        buttom.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        buttom.layer.cornerRadius = 16
        buttom.layer.masksToBounds = true
        buttom.addTarget(<#T##target: Any?##Any?#>, action: <#T##Selector#>, for: .touchUpInside)
        buttom.translatesAutoresizingMaskIntoConstraints = false
        return buttom
    }()
    
    private lazy var pages: [UIViewController] = {
        let blue = createPage(imageName: "onboardingBue")
        let red = createPage(imageName: "onboardingRed")
        return [blue, red]
    }()
    
    private  lazy var pageControl: UIPageControl = {
        let pageControll = UIPageControl()
        pageControll.numberOfPages = pages.count
        pageControll.currentPage = 0
        
        pageControll.currentPageIndicatorTintColor = .black
        pageControll.pageIndicatorTintColor = .gray
        
        pageControll.translatesAutoresizingMaskIntoConstraints = false
        return pageControll
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: true, completion: nil)
        }
    }
    
    private func createPage(imageName: String) -> UIViewController {
        let page = UIViewController()
        let backgroundImage = UIImageView(frame: view.bounds)
        backgroundImage.image = UIImage(named: imageName)
        backgroundImage.contentMode = .scaleAspectFill
        page.view.addSubview(backgroundImage)
        page.view.sendSubviewToBack(backgroundImage)
        return page
    }
    
    private func setupUI() {
        
        view.addSubview(pageControl)
        view.addSubview(buttom)
        
        NSLayoutConstraint.activate([
            
            pageControl.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            
            buttom.leftAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttom.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            buttom.widthAnchor.constraint(equalToConstant: 335),
            buttom.heightAnchor.constraint(equalToConstant: 60)
            
        ])
    }
}

extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        let previosIndex = viewControllerIndex - 1
        guard previosIndex >= 0 else {
            return pages.last
        }
        guard pages.count > previosIndex else {
            return nil
        }
        return pages[previosIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < pages.count else {
            return pages.first
        }
        return pages[nextIndex]
    }
}

extension OnboardingViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
        }
    }
}

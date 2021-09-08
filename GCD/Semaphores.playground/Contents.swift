/// Copyright (c) 2019 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import PlaygroundSupport

/*:
Tell the playground to continue running, even after it thinks execution has ended.
You need to do this when working with background tasks.
 */

PlaygroundPage.current.needsIndefiniteExecution = true

let group = DispatchGroup()
let queue = DispatchQueue.global(qos: .userInteractive)
let semaphore = DispatchSemaphore(value: 4)

let base = "https://wolverine.raywenderlich.com/books/con/image-from-rawpixel-id-"
let ids = [ 466881, 466910, 466925, 466931, 466978, 467028, 467032, 467042, 467052 ]
var images: [UIImage] = []

func wrappedURLSession(group: DispatchGroup, semaphore: DispatchSemaphore, url: URL, completion: @escaping (Data?, Error?) -> Void) {
    semaphore.wait()
    group.enter()
    URLSession.shared.dataTask(with: url) { data, _, error in
        defer {
            semaphore.signal()
            group.leave()
        }
        completion(data, error)
    }.resume()
}

for id in ids {
    guard let url = URL(string: "\(base)\(id)-jpeg.jpg") else { continue }
    wrappedURLSession(group: group, semaphore: semaphore, url: url) { data, error in
        if error == nil, let data = data, let image = UIImage(data: data) {
            images.append(image)
        }
    }
}

// Because we've not specified a time, this will wait indefinitely
group.wait()

PlaygroundPage.current.finishExecution()
/* Copyright 2019 The TensorFlow Authors. All Rights Reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
==============================================================================*/

namespace tf_plugin_host {

export enum HttpMethodType {
  GET = 'GET',
  POST = 'POST',
}

export class RequestOptions {
  public methodType: HttpMethodType;

  /** The content-type request header to use. Cannot be set for a GET request.*/
  public contentType?: string;

  /** The request body to use. This is the object that is passed to the
   * XMLHttpRequest.send() method. If not given the 'send' method is called
   * without an argument.
   */
  public body?: any;

  /** If specified, this will be the value set in the
   * XMLHttpRequest.withCredentials property.
   */
  public withCredentials?: boolean;

  // Validates this object. Throws InvalidRequestOptionsError on error.
  public validate() {
    if (this.methodType === HttpMethodType.GET) {
      // We don't allow a body for a GET.
      if (this.body) {
        throw new Error(
          'body must be missing for a GET request.');
      }
    }
    // We allow body-less or contentType-less POSTs even if they don't
    // make much sense.
  }
}

export enum MessageType {
  REQUEST,
  RESPONSE,
};

interface Message {
  type: MessageType,
  id: number,
}

export interface RequestMessage extends Message {
  url: string,
  options: RequestOptions,
}

const requestManager = new tf_backend.RequestManager();

window.addEventListener('message', (event) => {
  const message: RequestMessage = JSON.parse(event.data);
  const options = new RequestOptions();
  Object.assign(options, message.options);

  switch (message.type) {
    case MessageType.REQUEST:
      requestManager.requestWithOptions(message.url, options).then(response => {
        event.source.postMessage(JSON.stringify({
          type: MessageType.RESPONSE,
          id: message.id,
          response,
        }), '*');
      });
      break;
  }
});


export async function createIFrame(targetElement: HTMLElement, dashboard): Promise<HTMLIFrameElement> {
  const iframe = document.createElement('iframe');
  targetElement.appendChild(iframe);
  const doc = iframe.contentDocument;

  const url = new URL(window.location.href);
  url.pathname += `data/plugin/${dashboard.plugin}/`;
  const baseNode = doc.createElement('base');
  baseNode.href = url.toString();
  doc.head.appendChild(baseNode);

  const scriptNode = doc.createElement('script');
  scriptNode.src = dashboard.webfile;
  doc.head.appendChild(scriptNode);
  return iframe;
}

}  // namespace tf_plugin_host

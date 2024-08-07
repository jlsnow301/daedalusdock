import { Component } from 'react';

import { BoxProps, computeBoxProps } from './Box';

type Props = Partial<{
  /** True is default, this fixes an ie thing */
  fixBlur: boolean;
  /** False by default. Good if you're fetching images on UIs that do not auto update. This will attempt to fix the 'x' icon 5 times. */
  fixErrors: boolean;
  /** Fill is default. */
  objectFit: 'contain' | 'cover';
}> &
  IconUnion &
  BoxProps;

// at least one of these is required
type IconUnion =
  | {
      className?: string;
      src: string;
    }
  | {
      className: string;
      src?: string;
    };

const maxAttempts = 5;

/** Image component. Use this instead of Box as="img". */
export class Image extends Component<Props> {
  attempts: number;

  constructor(props: Props) {
    super(props);
  }

  render() {
    const {
      fixBlur = true,
      fixErrors = false,
      objectFit = 'fill',
      src,
      ...rest
    } = this.props;

    const computedProps = computeBoxProps(rest) as Record<string, any>;
    computedProps['style'] = {
      ...computedProps.style,
      '-ms-interpolation-mode': fixBlur ? 'nearest-neighbor' : 'auto',
      objectFit,
    };

    return (
      <img
        onError={(event) => {
          if (fixErrors && this.attempts < maxAttempts) {
            const imgElement = event.currentTarget;

            setTimeout(() => {
              imgElement.src = `${src}?attempt=${this.attempts}`;
              this.attempts++;
            }, 1000);
          }
        }}
        src={src}
        {...computedProps}
      />
    );
  }
}
